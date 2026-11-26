# Simplified Footprint

- url: https://www.tradingview.com/script/kszclif5-Simplified-Footprint/
- type: indicator
- pine_id: PUB;2d3830b78df8482d96fdf631fd962b06
- version: 3.0

## Description

If you've tried using volume footprint charts and been daunted with information overload, then this 'Simplified Footprint' indicator could be just what you need instead.

The POC and value area are overlayed onto regular candles on the chart.

The delta is plotted as an oscillator, but the fun part, also in the oscillator pane, are the imbalances.


A buy imbalance is shown as a green bar. If it goes upwards part way, then it is partly displaced by the price. Up to the top, and the price has fully displaced the imbalance.

If the green buy imbalance bar goes downwards however, then it's absorbed by passive sell orders. Part way, partly absorbed, all the way down, then fully absorbed.

The colour of the bars are also more transparent with low volume, and more opaque, as the volume in that direction increases.

The sell imbalances are red and do the opposite. Downwards, and they are displaced by price, upwards and they are absorbed.

To clearly see what's going on, you want the buy imbalance columns narrower than the sell imbalance columns (or vice versa).

These colours are all transparent to some degree so you can still read them when they overlay, but having the columns different widths, like piano keys, really makes reading them easier.

The absorptions are also marked with an 'A' to avoid any doubt.


Using this 'Simplified Footprint' indicator allows you to visually read all this footprint data at a glance, on a regular chart.

To make it even simpler, you can just view it as; imbalance bars and delta going upwards are bullish, going downwards, bearish.

Obviously you might want to pay attention to the absorptions, as they indicate passive participants having an effect on the market that you wouldn't otherwise see, as they don't move the price.


To use this indicator, you just need to configure the number of ticks per row, at the top of the settings.

This can be set with a number of ticks per row, or with an Average True Range (ATR), and can be scalable across different timeframes as well.

Probably the easiest way to use it is to select the timeframe on the chart you want to use, then get an ATR reading for that timeframe.

Then use that ATR value in the 'Simplified Footprint' settings.

If you scale the ticks for different timeframes, just specify the timeframe for which the ATR (or ticks) are calibrated for.


You will also probably need to tweak the narrow imbalance column width, depending on how zoomed into the chart you are, to get a piano key look for clarity.


Although the 'ticks per row' can be scaled across different timeframes, the scaling is an approximation and may not always work well, especially if the chart is far removed from the reference timeframe.

Ideally try not to scale too far from the reference timeframe, and re-calibrate nearer to the chart timeframe if necessary.

If in any doubt, check the Pine logs for configuration details and information about the last confirmed bar.

The last couple of lines, where it says:

  Last confirmed bar, rows per footprint: x

Use the above 'rows per footprint' as calibration, which should be between about 3 and 30 ideally, although more may still be OK.


The rows per footprint can be checked against the actual volume footprint, and should be the same if the ticks per row are the same.

However, the default value the actual volume footprint uses is 'auto', which cannot be replicated in this script due to the platform design.

So if you want the same number of rows per footprint, and see exactly the same imbalances, you need to configure the actual volume footprint with a manual row size and set the ticks per row to the same number as in this 'Simplified Footprint' indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JustinTimeTunes

//@version=6
indicator("Simplified Footprint", max_boxes_count = 10000)


// If you've tried using volume footprint charts and been daunted with information overload, then this 'Simplified Footprint' indicator could be just what you need instead.
// The POC and value area are overlayed onto regular candles on the chart.
// The delta is plotted as an oscillator, but the fun part, also in the oscillator pane, are the imbalances.
//
// A buy imbalance is shown as a green bar. If it goes upwards part way, then it is partly displaced by the price. Up to the top, and the price has fully displaced the imbalance.
// If the green buy imbalance bar goes downwards however, then it's absorbed by passive sell orders. Part way, partly absorbed, all the way down, then fully absorbed.
// The colour of the bars are also more transparent with low volume, and more opaque, as the volume in that direction increases.
// The sell imbalances are red and do the opposite. Downwards, and they are displaced by price, upwards and they are absorbed.
// To clearly see what's going on, you want the buy imbalance columns narrower than the sell imbalance columns (or vice versa).
// These colours are all transparent to some degree so you can still read them when they overlay, but having the columns different widths, like piano keys, really makes reading them easier.
// The absorptions are also marked with an 'A' to avoid any doubt.
//
// Using this 'Simplified Footprint' indicator allows you to visually read all this footprint data at a glance, on a regular chart.
// To make it even simpler, you can just view it as; imbalance bars and delta going upwards are bullish, going downwards, bearish.
// Obviously you might want to pay attention to the absorptions, as they indicate passive participants having an effect on the market that you wouldn't otherwise see, as they don't move the price.
//
// To use this indicator, you just need to configure the number of ticks per row, at the top of the settings.
// This can be set with a number of ticks per row, or with an Average True Range (ATR), and can be scalable across different timeframes as well.
// Probably the easiest way to use it is to select the timeframe on the chart you want to use, then get an ATR reading for that timeframe.
// Then use that ATR value in the 'Simplified Footprint' settings.
// If you scale the ticks for different timeframes, just specify the timeframe for which the ATR (or ticks) are calibrated for.
//
// You will also probably need to tweak the narrow imbalance column width, depending on how zoomed into the chart you are, to get a piano key look for clarity.
//
// Although the 'ticks per row' can be scaled across different timeframes, the scaling is an approximation and may not always work well, especially if the chart is far removed from the reference timeframe.
// Ideally try not to scale too far from the reference timeframe, and re-calibrate nearer to the chart timeframe if necessary.
//
// If in any doubt, select 'Show Rows Per Footprint' in the settings, which will display the number of rows for the last confirmed bar.
// Use this as calibration, which should be between about 3 and 30 ideally, although more may still be OK.
//
// The rows per footprint can be checked against the actual volume footprint, and should be the same if the ticks per row are the same.
// However, the default value the actual volume footprint uses is 'auto', which cannot be replicated in this script due to the platform design.
// So if you want the same number of rows per footprint, and see exactly the same imbalances, you need to configure the actual volume footprint with a manual row size and set the ticks per row
// to the same number as in this 'Simplified Footprint' indicator.
//
// Unfortunately, only accounts with Premium or Ultimate plans can use this script, as volume footprint information is restricted.


// Constants

const int MIN_TRANSPARENCY = 5
const int MAX_TRANSPARENCY = 95

const string TICKS = "Ticks"
const string TICKS_IN_ATR = "ATR"

const string FOOTPRINT_CALIBRATION_INFO = " for calibration, which should be between about 3 and 30 ideally, although more may still be OK."

const color TRANSPARENT_COLOUR = color.rgb(100, 100, 100, 100)


// Inputs

float ticksInput = input.float(defval = 1000, title = "Ticks / ATR", group = "Footprint - Ticks Per Row", inline = "Ticks", display = display.none)

string tickTypeInput = input.string(defval = TICKS, title = "", options = [TICKS, TICKS_IN_ATR], group = "Footprint - Ticks Per Row", inline = "Ticks", display = display.none,
    tooltip = "Specify either the number of ticks per row\nOR\nThe normalized ATR\n\nWhen using ATR, it will use the number of ticks in ATR * 0.2, as this is the auto formula used by Trading View."
    + " Unfortunately this must be set manually here due to platform design.")

bool scaleTicksInput = input.bool(defval = false, title = "Scale ticks", group = "Footprint - Ticks Per Row", inline = "scaleTicks", display = display.none)

string tickTimeframeInput = input.string(defval = "D", title = "-> Timeframe", display = display.none, options = ["1", "2", "3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "M"],
    group = "Footprint - Ticks Per Row", inline = "scaleTicks", tooltip = "Use this option to scale ticks for different timeframes. If so, the above tick settings will be used for this reference timeframe, to scale from.")

bool showRowsPerFootprintInput = input.bool(defval = true, title = "Show Rows Per Footprint", group = "Footprint - Ticks Per Row", inline = "rowsPerFoot", display = display.none,
    tooltip = "Display the 'rows per footprint' of the last confirmed bar, for calibration purposes.")

color labelColourInput = input.color(defval = color.rgb(33, 30, 228, 70), title = "", group = "Footprint - Ticks Per Row", inline = "rowsPerFoot", display = display.none)

color labelTextColourInput = input.color(defval = color.rgb(255, 255, 255, 30), title = "", group = "Footprint - Ticks Per Row", inline = "rowsPerFoot", display = display.none)


int imbalancePercentageInput = input.int(defval = 300, title = "Imbalance %", minval = 1, maxval = 100000000, group = "Footprint - Other Settings", display = display.none,
    tooltip = "The percentage difference between aggressive buy and sell volume to determine if there is an imbalance.")

int valueAreaPercentageInput = input.int(defval = 70, title = "Value Area %", minval = 1, maxval = 100, group = "Footprint - Other Settings", display = display.none,
    tooltip = "Percentage of trade volume for the value area.")


color pocColourInput = input.color(color.white, "POC", group = "Chart", display = display.none)

bool showValAreaInput = input.bool(defval = true, title = "Show", group = "Chart", inline = "valArea", display = display.none)

color valAreaColourInput = input.color(color.new(color.yellow, 70), "Value Area", group = "Chart", inline = "valArea", display = display.none)


color deltaColourInput = input.color(color.blue, "Delta", group = "Oscillator", display = display.none)


int imbalanceSizeInput = input.int(defval = 100, title = "Display Size %", minval = 1, maxval = 100000000, group = "Imbalances", display = display.none,
    tooltip = "Use this to adjust the size of the imbalances relative to the delta.")

bool fixedImbalanceSizeInput = input.bool(defval = false, title = "Fixed Imbalance Size", group = "Imbalances", display = display.none,
    tooltip = "By default it's dynamically sized to the match the delta, but if you don't like the curves, you can make it straight with a fixed size.")

color buyImbalanceColourInput = input.color(color.rgb(8, 153, 66), "Buy", group = "Imbalances", display = display.none)

color sellImbalanceColourInput = input.color(color.rgb(236, 10, 53), "Sell", group = "Imbalances", display = display.none)

int colourBrightnessInput = input.int(defval = 100, title = "Colour Brightness %", minval = 0, maxval = 10000, group = "Imbalances", display = display.none,
    tooltip = "Control the brightness of the imbalance colours.")

bool narrowBuyImbalancesInput = input.bool(defval = true, title = "Narrow Buy Imbalances", group = "Imbalances", display = display.none, tooltip = "Display narrow buy imbalances and wide sell, otherwise narrow sell and wide buy.")

int narrowImbalanceWidthInput = input.int(defval = 10, title = "Narrow Column Width", minval = 1, maxval = 500, group = "Imbalances", display = display.none)

bool showAbsorptionInput = input.bool(defval = true, title = "Show Absorptions", group = "Imbalances", display = display.none)


// Functions

comparePriceWithImbalance(imbalanceLow, imbalanceHigh, thisPrice) =>
    
    result = 0.0

    if imbalanceLow == 0 or imbalanceHigh == 0
        result
    else
        if thisPrice < imbalanceLow
            result := -1
        else if thisPrice > imbalanceHigh
            result := 1
        else
            result := (thisPrice - imbalanceLow) / (imbalanceHigh - imbalanceLow)
            result *= 2
            result -= 1

        result


analizeImbalances(footprintRows, buy, thisPrice) =>

    imbalanceLow = 0.0
    imbalanceHigh = 0.0

    for thisRow in footprintRows
        
        hasImbalance = false

        if buy
            hasImbalance := volume_row.has_buy_imbalance(thisRow)
        else
            hasImbalance := volume_row.has_sell_imbalance(thisRow)


        if hasImbalance
            if imbalanceLow == 0
                imbalanceLow := thisRow.down_price()

            imbalanceHigh := thisRow.up_price()

    comparePriceWithImbalance(imbalanceLow, imbalanceHigh, thisPrice)


getTransparency(value, valHigh) =>
    MIN_TRANSPARENCY + ((MAX_TRANSPARENCY - MIN_TRANSPARENCY) * (1 - (value / valHigh)))


getTimeframeMinutes(timeframeStr) =>
    float mins = switch timeframeStr
        "D" => 1440
        "W" => 10080
        "M" => 44640
        => str.tonumber(timeframeStr)

    int(mins)


// Variables

float thisDelta = 0

float buyVolume = 0
float sellVolume = 0

float buyImbalance = 0
float sellImbalance = 0

float poc = 0

float valAreaHigh = 0
float valAreaLow = 0

var staticImbalanceRange = 0.0


// Calculations

int ticks = math.round(ticksInput)

if tickTypeInput == TICKS_IN_ATR
    ticks := math.round((ticksInput * 0.2) / syminfo.mintick)


int timeframeMinutes = timeframe.in_seconds() / 60

int tickTimeframeMins = getTimeframeMinutes(tickTimeframeInput)


int timeframeTicksPerRow = ticks

if scaleTicksInput
    timeframeTicksPerRow := int(timeframeTicksPerRow * (timeframeMinutes / tickTimeframeMins))


footprint thisFootprint = request.footprint(ticks_per_row = timeframeTicksPerRow, va_percent = valueAreaPercentageInput, imbalance_percent = imbalancePercentageInput)

if na(thisFootprint) == false

    array<volume_row> rows = footprint.rows(thisFootprint)

    if barstate.islastconfirmedhistory
        log.info("Ticks input: " + str.tostring(ticksInput))
        log.info("Tick type input: " + tickTypeInput)
        log.info("Minimum tick: " + str.tostring(syminfo.mintick))
        log.info("Ticks per row: " + str.tostring(ticks))
        log.info("Current timeframe minutes: " + str.tostring(timeframeMinutes))
        log.info("Tick timeframe mins: " + str.tostring(tickTimeframeMins))
        log.info("Scale ticks to timeframe: " + str.tostring(scaleTicksInput))
        log.info("Timeframe ticks per row: " + str.tostring(timeframeTicksPerRow))
        log.info("Last confirmed bar, time (GMT): " + str.format_time(time, "d MMM yyyy, HH:mm", "GMT"))
        log.info("Last confirmed bar, open: " + str.tostring(open))
        log.info("Last confirmed bar, close: " + str.tostring(close))
        log.info("Last confirmed bar, rows per footprint: " + str.tostring(rows.size()))
        log.info("Use the above 'rows per footprint'" + FOOTPRINT_CALIBRATION_INFO)

        if showRowsPerFootprintInput

            labelPoint = chart.point.now(close)

            label.new(point = labelPoint, text = "Rows per footprint: " + str.tostring(rows.size()), style = label.style_label_down, size = size.large, force_overlay = true, yloc = yloc.abovebar,
                color = labelColourInput, textcolor = labelTextColourInput, tooltip = "Use this" + FOOTPRINT_CALIBRATION_INFO + "\n\nThis label can be turned off in settings.")


    buyImbalance := analizeImbalances(rows, true, close)
    sellImbalance := analizeImbalances(rows, false, close)

    thisDelta := thisFootprint.delta()

    buyVolume := thisFootprint.buy_volume()
    sellVolume := thisFootprint.sell_volume()

    pocRow = thisFootprint.poc()

    poc := (pocRow.up_price() + pocRow.down_price()) / 2


    valAreaHigh := thisFootprint.vah().up_price()

    valAreaLow := thisFootprint.val().down_price()


// GUI

deltaRange = ta.median(math.abs(thisDelta), 200)

imbalanceRange = ta.sma(deltaRange * 4, 100)

imbalanceRange *= (imbalanceSizeInput / 100)


if staticImbalanceRange == 0 and imbalanceRange > 0
    staticImbalanceRange := imbalanceRange

if fixedImbalanceSizeInput
    imbalanceRange := staticImbalanceRange


buyVolHigh = ta.sma(ta.median(buyVolume, 100), 100)
sellVolHigh = ta.sma(ta.median(sellVolume, 100), 100)

highVol = math.max(buyVolHigh, sellVolHigh) * 2

buyColour = color.new(buyImbalanceColourInput, getTransparency(buyVolume * (colourBrightnessInput / 100), highVol))
sellColour = color.new(sellImbalanceColourInput, getTransparency(sellVolume * (colourBrightnessInput / 100), highVol))


buyImbalanceStyle = plot.style_columns
sellImbalanceStyle = plot.style_histogram

if narrowBuyImbalancesInput
    buyImbalanceStyle := plot.style_histogram
    sellImbalanceStyle := plot.style_columns

plot(series = sellImbalance * imbalanceRange, title = "Sell Imbalance", style = sellImbalanceStyle, color = sellColour, linewidth = narrowImbalanceWidthInput)
plot(series = buyImbalance * imbalanceRange, title = "Buy Imbalance", style = buyImbalanceStyle, color = buyColour, linewidth = narrowImbalanceWidthInput)

plot(series = imbalanceRange, title = "Imbalance Max", style = plot.style_line, color=color.new(color.gray, 40), linewidth = 2)
plot(series = imbalanceRange * -1, title = "Imbalance Min", style = plot.style_line, color=color.new(color.gray, 40), linewidth = 2)

plot(series = thisDelta, title = "Delta", linewidth = 3, color = deltaColourInput)

plot(series = poc, title = "POC", style = plot.style_stepline, linewidth = 2, color = pocColourInput, force_overlay = true)

hline(price = 0, title = "zero", color=color.new(color.white, 20), linestyle = hline.style_solid, linewidth = 2)

vahPlot = plot(series = valAreaHigh, title = "Value Area High", style = plot.style_line, linewidth = 1, color = TRANSPARENT_COLOUR, force_overlay = true)
valPlot = plot(series = valAreaLow, title = "Value Area Low", style = plot.style_line, linewidth = 1, color = TRANSPARENT_COLOUR, force_overlay = true)


valAreaColour = TRANSPARENT_COLOUR

if showValAreaInput
    valAreaColour := valAreaColourInput

fill(plot1 = vahPlot, plot2 = valPlot, color = valAreaColour, title = "Value Area")


if showAbsorptionInput
    chart.point topLeftSellPoint = chart.point.now(imbalanceRange * 1.2)
    chart.point bottomRightSellPoint = chart.point.now(imbalanceRange * 1.1)

    if sellImbalance > 0
        box.new(top_left = topLeftSellPoint, bottom_right = bottomRightSellPoint, text = "A", text_size = 14, text_formatting = text.format_bold, text_color = sellColour, border_color = TRANSPARENT_COLOUR, bgcolor = TRANSPARENT_COLOUR, border_width = 0, extend = extend.none)

    chart.point topLeftBuyPoint = chart.point.now(imbalanceRange * -1.1)
    chart.point bottomRightBuyPoint = chart.point.now(imbalanceRange * -1.2)

    if buyImbalance < 0
        box.new(top_left = topLeftBuyPoint, bottom_right = bottomRightBuyPoint, text = "A", text_size = 14, text_formatting = text.format_bold, text_color = buyColour, border_color = TRANSPARENT_COLOUR, bgcolor = TRANSPARENT_COLOUR, border_width = 0, extend = extend.none)
````

# Simple Relative Strength

- url: https://www.tradingview.com/script/I1XzVm6s-Simple-Relative-Strength/
- type: indicator
- pine_id: PUB;58b4a1f7badf42c593e7f07fffdfbab6
- version: 1.0

## Description

This 'Simple Relative Strength' (SRS) indicator is similar to RSI in that it's a measure of relative strength, except that it's calculated entirely differently.

This means that although it may look similar, it may also look and behave very differently depending on the settings.

It is calculated from a time period, specified by a number of bars, hours or days.

The SRS value is the current price, expressed as a percentage of the price range, from low to high, of the specified time period.

This is my own invention, and not like anything else, that I'm aware of.

I currently use this SRS as one of the indicators, within a more complex live trading strategy for my bots, trading on Bitcoin and Gold.

I did initially try using an RSI or CMF within my strategy, but found this SRS to be more useful instead.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JustinTimeTunes

// This 'Simple Relative Strength' (SRS) indicator is similar to RSI in that it's a measure of relative strength, except that it's calculated entirely differently.
// This means that although it may look similar, it may also look and behave very differently depending on the settings.
// It is calculated from a time period, specified by a number of bars, hours or days.
// The SRS value is the current price, expressed as a percentage of the price range, from low to high, of the specified time period.
// This is my own invention, and not like anything else, that I'm aware of.
// I currently use this SRS as one of the indicators, within a more complex live trading strategy for my bots, trading on Bitcoin and Gold.
// I did initially try using an RSI or CMF within my strategy, but found this SRS to be more useful instead.


//@version=6
indicator(title = "Simple Relative Strength", shorttitle = "SRS")


// Constants

const int MS_MINUTE = 1000 * 60
const int MS_HOUR = MS_MINUTE * 60
const int MS_DAY = MS_HOUR * 24


// Inputs

durationInput = input.int(defval = 400, title = "Duration", minval = 1, maxval = 1000000, group = "Time Period", inline = "Duration",
    tooltip = "Time period from which the Simple Relative Strength is calculated.\n\nN.B. The plot won't show if the time period is greater than that of the price data.")

durationTypeInput = input.string(defval = "Bars", title = "", options = ["Bars", "Hours", "Days"], group = "Time Period", inline = "Duration")

smaLengthInput = input.int(defval = 40, title = "Length", minval = 1, maxval = 1000000, group = "SMA")


// Calculations

int barDuration = time_close - time

int noOfBarsInTimePeriod = durationInput


if durationTypeInput == "Hours"
    noOfBarsInTimePeriod := (MS_HOUR * durationInput) / barDuration

else if durationTypeInput == "Days"
    noOfBarsInTimePeriod := (MS_DAY * durationInput) / barDuration


if noOfBarsInTimePeriod < 1
    noOfBarsInTimePeriod := 1


float periodHigh = ta.highest(noOfBarsInTimePeriod)
float periodLow = ta.lowest(noOfBarsInTimePeriod)

float priceRange = periodHigh - periodLow    // always positive

float relativeStrength = ((close - periodLow) / priceRange) * 100

float relativeStrengthSMA = ta.sma(relativeStrength, smaLengthInput)


// GUI

srsPlot = plot(series = relativeStrength, title = "SRS", linewidth = 1, color = color.yellow)
smaPlot = plot(series = relativeStrengthSMA, title = "SRS SMA", linewidth = 2, color = color.blue)

midline = hline(price = 50, title = "Midline", color=color.new(#787B86, 50), linestyle = hline.style_dotted)
midLinePlot = plot(series = 50, color = na, editable = false, display = display.none)

overboughtLevel = hline(price = 80, title = "Overbought Level", color = #787B86, linestyle = hline.style_solid)
oversoldLevel = hline(price = 20, title = "Oversold Level", color = #787B86, linestyle = hline.style_solid)
fill(hline1 = overboughtLevel, hline2 = oversoldLevel, color = color.rgb(26, 7, 94, 90), title = "SRS Background")

fill(plot1 = srsPlot, plot2 = midLinePlot, top_value = 100, bottom_value = 60, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "Overbought Gradient")
fill(plot1 = srsPlot, plot2 = midLinePlot, top_value = 40, bottom_value = 0, top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "Oversold Gradient")
````

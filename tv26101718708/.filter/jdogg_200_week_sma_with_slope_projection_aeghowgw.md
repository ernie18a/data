# JDOGG 200 Week SMA with Slope Projection

- url: https://www.tradingview.com/script/AeGhOWGw-JDOGG-200-Week-SMA-with-Slope-Projection/
- type: indicator
- pine_id: PUB;5209c622367f48fd8d38c0da708681e1
- version: 1.0

## Description

This is a 200 week moving average with a % band around it and a projection into the future to visualize how it will look if the trend persists.

## Source Code

````pine
//@version=5
indicator("200 Week SMA with Slope Projection", overlay=true)

// --- Inputs ---
smaLength    = input.int(200, minval=1, title="SMA Length")
bandPercent  = input.float(10.0, minval=0.1, title="Band Percentage (%)")
lookbackWks  = input.int(104, title="Slope Lookback (Weeks)", tooltip="104 weeks = 2 years")
projectBars  = input.int(50, title="Projection Distance (Bars)", tooltip="How many bars into the future to project")
src          = input(close, title="Source")

// --- Calculations ---
// 1. Get the Weekly SMA
weeklySMA = request.security(syminfo.tickerid, "W", ta.sma(src, smaLength))

// 2. Calculate Slope manually (Rise over Run)
// We use Linear Regression to find the 'trend' of the SMA itself over the lookback
lrValue      = ta.linreg(weeklySMA, lookbackWks, 0)
lrValuePast  = ta.linreg(weeklySMA, lookbackWks, 1)
slope        = lrValue - lrValuePast

// 3. Band Calculations
bandMultiplier = bandPercent / 100
upperBand = weeklySMA * (1 + bandMultiplier)
lowerBand = weeklySMA * (1 - bandMultiplier)

// --- Plotting Current Data ---
plot(weeklySMA, color=color.new(color.white, 0), linewidth=2, title="200 Week SMA")
p1 = plot(upperBand, color=color.new(color.green, 50), title="Upper Band")
p2 = plot(lowerBand, color=color.new(color.red, 50), title="Lower Band")
fill(p1, p2, color=color.new(color.gray, 90), title="Band Background")

// --- Future Projection Logic ---
// Create the lines (var ensures they are only created once and then moved)
var line mainLine  = line.new(na, na, na, na, color=color.white, style=line.style_dashed, width=2)
var line upperLine = line.new(na, na, na, na, color=color.green, style=line.style_dashed, width=1)
var line lowerLine = line.new(na, na, na, na, color=color.red, style=line.style_dashed, width=1)

if barstate.islast
    // Calculate the projection based on the current slope
    float futureSMA   = weeklySMA + (slope * projectBars)
    float futureUpper = upperBand + (slope * projectBars)
    float futureLower = lowerBand + (slope * projectBars)

    // Update Mid Line
    line.set_xy1(mainLine,  bar_index, weeklySMA)
    line.set_xy2(mainLine,  bar_index + projectBars, futureSMA)
    
    // Update Upper Line
    line.set_xy1(upperLine, bar_index, upperBand)
    line.set_xy2(upperLine, bar_index + projectBars, futureUpper)
    
    // Update Lower Line
    line.set_xy1(lowerLine, bar_index, lowerBand)
    line.set_xy2(lowerLine, bar_index + projectBars, futureLower)
````

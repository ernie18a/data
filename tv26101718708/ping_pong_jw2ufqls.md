# PING PONG

- url: https://www.tradingview.com/script/jw2uFQlS-PING-PONG/
- type: indicator
- pine_id: PUB;99cfe91a367045499ff96734ee4a93e0
- version: 1.0

## Description

Ping Pong Hourly Grid Generator is a session-based grid plotting indicator designed for traders who prefer structured price action trading around predefined hourly levels. The indicator automatically creates a symmetric price grid at the beginning of every hourly session using the opening price as the reference point.

The generated grid acts as a framework for identifying high-probability support, resistance, reversal, and breakout zones throughout the trading session.

Features
✅ Automatic Hourly Grid
Creates a new grid at the start of every hour.
Uses the hourly opening price as the central reference.
Old grids remain on the chart for historical analysis.

## Source Code

````pine
//@version=6
indicator("PING PONG Grid V1", overlay=true)

//====================================================
// INPUTS
//====================================================

spacing = input.float(200.0, "Grid Spacing")

showExpansionGrid = input.bool(false, "Show Expansion Grid")

showBackground = input.bool(true, "Show Background Fill")

bgTransparency = input.int(90, "Background Transparency", minval=0, maxval=100)

//====================================================
// HOURLY GRID
//====================================================

newHour = minute(time) == 0 and minute(time[1]) != 0

var float anchorOpen = na

if newHour
    anchorOpen := open

if na(anchorOpen)
    anchorOpen := open

//====================================================
// BASE LEVELS
//====================================================

level0  = anchorOpen

levelP1 = anchorOpen + spacing
levelP2 = anchorOpen + spacing * 2

levelM1 = anchorOpen - spacing
levelM2 = anchorOpen - spacing * 2

//====================================================
// EXPANSION LEVELS
//====================================================

levelP3  = levelP2  + spacing
levelP4  = levelP3  + spacing
levelP5  = levelP4  + spacing
levelP6  = levelP5  + spacing
levelP7  = levelP6  + spacing
levelP8  = levelP7  + spacing
levelP9  = levelP8  + spacing
levelP10 = levelP9  + spacing

levelM3  = levelM2  - spacing
levelM4  = levelM3  - spacing
levelM5  = levelM4  - spacing
levelM6  = levelM5  - spacing
levelM7  = levelM6  - spacing
levelM8  = levelM7  - spacing
levelM9  = levelM8  - spacing
levelM10 = levelM9  - spacing

//====================================================
// BASE GRID PLOTS
//====================================================

pP2 = plot(levelP2,
     title="P2",
     color=color.red,
     linewidth=2,
     style=plot.style_stepline)

pP1 = plot(levelP1,
     title="P1",
     color=color.orange,
     linewidth=2,
     style=plot.style_stepline)

p0 = plot(level0,
     title="Center",
     color=color.yellow,
     linewidth=3,
     style=plot.style_stepline)

pM1 = plot(levelM1,
     title="M1",
     color=color.aqua,
     linewidth=2,
     style=plot.style_stepline)

pM2 = plot(levelM2,
     title="M2",
     color=color.lime,
     linewidth=2,
     style=plot.style_stepline)

//====================================================
// EXPANSION GRID
//====================================================

pP3  = plot(showExpansionGrid ? levelP3  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP4  = plot(showExpansionGrid ? levelP4  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP5  = plot(showExpansionGrid ? levelP5  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP6  = plot(showExpansionGrid ? levelP6  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP7  = plot(showExpansionGrid ? levelP7  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP8  = plot(showExpansionGrid ? levelP8  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP9  = plot(showExpansionGrid ? levelP9  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pP10 = plot(showExpansionGrid ? levelP10 : na, color=color.blue, linewidth=1, style=plot.style_stepline)

pM3  = plot(showExpansionGrid ? levelM3  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM4  = plot(showExpansionGrid ? levelM4  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM5  = plot(showExpansionGrid ? levelM5  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM6  = plot(showExpansionGrid ? levelM6  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM7  = plot(showExpansionGrid ? levelM7  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM8  = plot(showExpansionGrid ? levelM8  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM9  = plot(showExpansionGrid ? levelM9  : na, color=color.blue, linewidth=1, style=plot.style_stepline)
pM10 = plot(showExpansionGrid ? levelM10 : na, color=color.blue, linewidth=1, style=plot.style_stepline)

//====================================================
// BACKGROUND FILLS
//====================================================

// Base Grid

fill(pP2, pP1,
     color = showBackground ? color.new(color.red, bgTransparency) : na)

fill(pP1, p0,
     color = showBackground ? color.new(color.orange, bgTransparency) : na)

fill(p0, pM1,
     color = showBackground ? color.new(color.aqua, bgTransparency) : na)

fill(pM1, pM2,
     color = showBackground ? color.new(color.lime, bgTransparency) : na)

// Expansion Upper

fill(pP2, pP3,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP3, pP4,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP4, pP5,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP5, pP6,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP6, pP7,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP7, pP8,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP8, pP9,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pP9, pP10, color=showBackground ? color.new(color.blue, bgTransparency) : na)

// Expansion Lower

fill(pM2, pM3,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM3, pM4,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM4, pM5,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM5, pM6,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM6, pM7,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM7, pM8,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM8, pM9,  color=showBackground ? color.new(color.blue, bgTransparency) : na)
fill(pM9, pM10, color=showBackground ? color.new(color.blue, bgTransparency) : na)
````

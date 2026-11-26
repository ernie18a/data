# PMH / PML Each Day

- url: https://www.tradingview.com/script/xPXpVCRN-PMH-PML-Each-Day/
- type: indicator
- pine_id: PUB;62cc3afd59004b108d3701fe1e2949dc
- version: 1.0

## Description

# PMH / PML Each Day Levels

This indicator automatically plots the **Previous Market High (PMH)** and **Previous Market Low (PML)** for every trading day using **Regular Trading Hours (RTH)** only.

### Features

* Plots the Previous Market High (PMH) and Previous Market Low (PML) for every trading session.
* Uses only **9:30 AM – 4:00 PM (Regular Market Hours)**.
* Draws historical PMH/PML levels for every day, making it ideal for backtesting.
* Each day's levels are displayed independently and do not overwrite previous sessions.
* Clean horizontal lines help identify important support and resistance levels.
* Works across all intraday timeframes.
* Perfect for price action, ORB, liquidity sweeps, and breakout/reversal strategies.

### Ideal For

* Intraday traders
* Opening Range Breakout (ORB) traders
* Support & Resistance analysis
* Historical chart review and backtesting
* Liquidity and market structure traders

This indicator provides a simple and reliable way to visualize the previous day's key market levels, allowing traders to quickly identify areas where price may react during the current trading session.

## Source Code

````pine
//@version=6
indicator("PMH / PML Each Day", overlay=true, max_lines_count=500)

premarketSession = input.session("0400-0929", "Premarket Session")
regularSession   = input.session("0930-1600", "Regular Session")

pmhColor  = input.color(color.green, "PMH Color")
pmlColor  = input.color(color.red, "PML Color")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

inPremarket = not na(time(timeframe.period, premarketSession))
inRegular   = not na(time(timeframe.period, regularSession))
newDay      = ta.change(time("D")) != 0

var float pmh = na
var float pml = na
var line pmhLine = na
var line pmlLine = na

// New day: reset values, but DO NOT delete previous day's lines
if newDay
    pmh := na
    pml := na
    pmhLine := na
    pmlLine := na

// Calculate premarket high/low for that day
if inPremarket
    pmh := na(pmh) ? high : math.max(pmh, high)
    pml := na(pml) ? low : math.min(pml, low)

// Draw that day's PMH/PML only during that day's regular session
if inRegular and not na(pmh) and not na(pml)
    if na(pmhLine)
        pmhLine := line.new(bar_index, pmh, bar_index, pmh, extend=extend.none, color=pmhColor, width=lineWidth)
        pmlLine := line.new(bar_index, pml, bar_index, pml, extend=extend.none, color=pmlColor, width=lineWidth)
    else
        line.set_x2(pmhLine, bar_index)
        line.set_x2(pmlLine, bar_index)
        line.set_y1(pmhLine, pmh)
        line.set_y2(pmhLine, pmh)
        line.set_y1(pmlLine, pml)
        line.set_y2(pmlLine, pml)
````

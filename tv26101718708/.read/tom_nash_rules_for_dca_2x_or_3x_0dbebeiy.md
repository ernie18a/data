# Tom Nash Rules for DCA + 2X or 3X

- url: https://www.tradingview.com/script/0DBEbEiY-Tom-Nash-Rules-for-DCA-2X-or-3X/
- type: indicator
- pine_id: PUB;5961424a839541649fddfa11f54be974
- version: 1.0

## Description

[b]The Rational Discount Tracker: A Value Investor’s Guide to Buying the Fear[/b]

[b]The Philosophy: Data Over Emotion[/b]
In the markets, whether you are looking at equities or digital assets, emotion is the enemy of retail investors. When the market bleeds, the masses panic-sell high-quality assets at a steep loss.

Financial analyst and commentator Tom Nash champions a distinctly contrarian, data-driven approach to these moments: Buy the fear, but only when the fundamentals haven't changed. When a high-conviction asset drops 20%, 25%, or 30% from its recent highs, it isn't necessarily a falling knife—it’s a systemic discount.

However, timing these entries requires stripping away the noise of the 15-minute chart and looking at the macro picture. That is exactly what this indicator is designed to do. It visually maps out your predefined "discount zones" while simultaneously monitoring the broader macroeconomic health via the S&P 500.

[b]Core Features[/b]
[b]1. The "Discount Zone" Ray[/b]
Instead of cluttering your chart with moving averages and lagging oscillators, this indicator cuts straight to the point. It identifies the absolute highest high over your chosen lookback period (default 365 bars for 24/7 markets) and draws an infinite, clean ray at your target discount level (selectable in 5% increments).

[b]The Nash Play[/b]: If you have high conviction in an asset's utility, set the drop line to 20% or 30%. When the price crosses this line, it signals that the asset has entered a historically significant discount territory, triggering your Dollar Cost Averaging (DCA) strategy.

[b]2. Independent Macro Tracking (The S&P 500 HUD)[/b]
You cannot accurately assess a dip without understanding the broader market context. Is your asset bleeding because of terrible internal news, or is it bleeding because the entire market is experiencing a liquidity crunch?

This indicator features a customizable, floating Heads-Up Display (HUD) that tracks the S&P 500’s distance from its All-Time High, completely independent of the chart you are currently viewing.

Real-Time Warning: If the S&P 500 drops past your specified percentage, the HUD flashes red. This tells you instantly if the discount in your specific asset is a localized event or a macro-level market correction.

[b]3. ATH and ATL Visualizers[/b]
Toggle on the 1-Year High (ATH) and 1-Year Low (ATL) rays to instantly visualize the asset's macro trading range. All lines are formatted dynamically, scaling perfectly whether you are tracking fractional cent assets or legacy blue-chip stocks.

[b]How to Trade With It[/b]
This tool is not a signal to blindly buy every dip. It is a framework for disciplined accumulation.

Do the Fundamental Work First: Identify assets with strong balance sheets, clear utility, and long-term viability.

Set Your Trap: Adjust the indicator to reflect your target entry discount (e.g., 20% from the 1-Year High).

Monitor the Macro: Watch the S&P 500 table. If the broader market is flashing red alongside your asset, you are likely looking at a systemic overreaction—the exact environment where generational wealth is built.

[b]Execute:[/b] When price action drops below your purple ray, ignore the market panic, trust your fundamental research, and execute your DCA strategy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © R2D2_4Life
//
// [ R2-D2 TOM NASH RULES FOR DCA + 2X OR 3X ]
//
//                 ___
//                / ()\
//              _|_____|_
//             | | === | |
//             |_|  O  |_|
//              ||_____||
//            _/_|_   _|_\_
//           (_____) (_____)
//
//@version=5
indicator("Tom Nash Rules for DCA + 2X or 3X", overlay=true, shorttitle="R2D2 DCA + 2 or 3X*")
 
// Tom Nash says that if the S&P 500 drops below 10%, DCA + 2X
// Otherwise, if a stock drops 20% below 52-week ATH, DCA + 3X

// --- Inputs: Main Chart Settings ---
lookbackPeriod = input.int(365, title="Lookback Period (Bars)", minval=1, group="Main Chart Settings")
dropPercentage = input.int(20, title="Drop Percentage (%)", options=[5, 10, 15, 20, 25, 30], group="Main Chart Settings")

// --- Inputs: ATH / ATL Rays ---
showAth = input.bool(true, title="Show ATH Ray (1-Year High)?", group="High/Low Rays")
showAtl = input.bool(true, title="Show ATL Ray (1-Year Low)?", group="High/Low Rays")

// --- Inputs: S&P 500 Table ---
showSPTable    = input.bool(true, title="Show S&P 500 Table?", group="S&P 500 Table Options")
spTicker       = input.symbol("SP:SPX", title="S&P 500 Ticker", group="S&P 500 Table Options")
tablePosInput  = input.string("Bottom Right", title="Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="S&P 500 Table Options")
tableSizeInput = input.string("Small", title="Table Size", options=["Tiny", "Small", "Normal"], group="S&P 500 Table Options")

// --- Calculations: Main Chart ---
highestHigh = ta.highest(high, lookbackPeriod)
lowestLow   = ta.lowest(low, lookbackPeriod)
targetLevel = highestHigh * (1 - (dropPercentage / 100.0))

// --- Drawing Variables ---
var line dropLine = na
var label dropLabel = na
var line athLine = na
var label athLabel = na
var line atlLine = na
var label atlLabel = na

if barstate.islast
    // Clear old lines/labels as price updates
    if not na(dropLine)
        line.delete(dropLine)
    if not na(dropLabel)
        label.delete(dropLabel)
    if not na(athLine)
        line.delete(athLine)
    if not na(athLabel)
        label.delete(athLabel)
    if not na(atlLine)
        line.delete(atlLine)
    if not na(atlLabel)
        label.delete(atlLabel)
    
    // Draw the Percentage Drop Line & Label
    dropLine := line.new(x1=bar_index - 1, y1=targetLevel, x2=bar_index, y2=targetLevel, extend=extend.both, color=color.purple, width=1)
    dropLabelStr = str.tostring(dropPercentage) + "% from ATH - " + str.tostring(targetLevel, format.mintick)
    dropLabel := label.new(x=bar_index + 2, y=targetLevel, text=dropLabelStr, color=color.new(color.white, 100), textcolor=color.silver, style=label.style_label_left, size=size.normal)

    // Draw the ATH Ray & Label if enabled
    if showAth
        athLine := line.new(x1=bar_index - 1, y1=highestHigh, x2=bar_index, y2=highestHigh, extend=extend.both, color=color.purple, width=1)
        athLabelStr = "52 week ATH - " + str.tostring(highestHigh, format.mintick)
        athLabel := label.new(x=bar_index + 2, y=highestHigh, text=athLabelStr, color=color.new(color.white, 100), textcolor=color.silver, style=label.style_label_left, size=size.normal)

    // Draw the ATL Ray & Label if enabled
    if showAtl
        atlLine := line.new(x1=bar_index - 1, y1=lowestLow, x2=bar_index, y2=lowestLow, extend=extend.both, color=color.purple, width=1)
        atlLabelStr = "52 week ATL - " + str.tostring(lowestLow, format.mintick)
        atlLabel := label.new(x=bar_index + 2, y=lowestLow, text=atlLabelStr, color=color.new(color.white, 100), textcolor=color.silver, style=label.style_label_left, size=size.normal)

// --- S&P 500 Data Fetch ---
[spHighs, spClose] = request.security(spTicker, timeframe.period, [ta.highest(high, lookbackPeriod), close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// --- S&P 500 Table Logic ---
var tablePos = position.bottom_right
if tablePosInput == "Top Left"
    tablePos := position.top_left
else if tablePosInput == "Top Center"
    tablePos := position.top_center
else if tablePosInput == "Top Right"
    tablePos := position.top_right
else if tablePosInput == "Middle Left"
    tablePos := position.middle_left
else if tablePosInput == "Middle Center"
    tablePos := position.middle_center
else if tablePosInput == "Middle Right"
    tablePos := position.middle_right
else if tablePosInput == "Bottom Left"
    tablePos := position.bottom_left
else if tablePosInput == "Bottom Center"
    tablePos := position.bottom_center

var tableSize = size.small
if tableSizeInput == "Tiny"
    tableSize := size.tiny
else if tableSizeInput == "Normal"
    tableSize := size.normal

var table spTable = na

if showSPTable
    if barstate.isfirst
        spTable := table.new(tablePos, columns=2, rows=4, border_width=1, border_color=color.new(color.gray, 50), frame_width=1, frame_color=color.new(color.gray, 50))
        table.merge_cells(spTable, 0, 0, 1, 0) 

    if barstate.islast
        spATH = spHighs
        spCurrent = spClose
        
        spDropPercent = spATH > 0 ? ((spATH - spCurrent) / spATH) * 100.0 : 0.0
        isFlashing = spDropPercent >= dropPercentage
        
        flashRed = (second(timenow) % 2 == 0) ? color.new(color.red, 30) : color.new(color.red, 80)
        bgCol = isFlashing ? flashRed : color.new(color.black, 80)
        textCol = color.white
        
        table.cell(spTable, 0, 0, "S&P 500", text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        table.cell(spTable, 0, 1, "ATH", text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        table.cell(spTable, 1, 1, str.tostring(spATH, "#.##"), text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        table.cell(spTable, 0, 2, "Current", text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        table.cell(spTable, 1, 2, str.tostring(spCurrent, "#.##"), text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        
        dropLabelStrTb = str.tostring(dropPercentage) + "% from ATH"
        dropValStrTb = str.tostring(spDropPercent, "#.##") + "%"
        table.cell(spTable, 0, 3, dropLabelStrTb, text_color=textCol, text_size=tableSize, bgcolor=bgCol)
        table.cell(spTable, 1, 3, dropValStrTb, text_color=textCol, text_size=tableSize, bgcolor=bgCol)

// May the trades be with you.
````

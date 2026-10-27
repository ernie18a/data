# Opens [by Roman]

- url: https://www.tradingview.com/script/bQWFcWJG-Opens-by-Roman/
- type: indicator
- pine_id: PUB;7707d6089fc341ae8692b530c7d8ddbf
- version: 1.0

## Description

This indicator displays the most important higher timeframe reference levels directly on the chart with clean horizontal lines and labels.

Included levels:
• Previous Day High (PDH)
• Previous Day Low (PDL)
• H4 Open
• Daily Open
• Weekly Open
• Monthly Open
• Yearly Open

Features:
• Minimalistic design for clean charting
• Labels displayed on the right side of each level
• Adjustable line length and label spacing
• Individual ON/OFF toggle for every level
• Custom color selection for each line
• Useful for liquidity mapping, bias determination, dealing ranges, and session analysis

This tool is designed for traders using:
• ICT / Smart Money Concepts
• Price Action
• Session-based trading
• Liquidity and dealing range analysis

The script helps quickly identify key higher timeframe levels that often act as:
• Support / resistance
• Liquidity targets
• Reaction zones
• Intraday bias references

Works on all markets and timeframes including:
• Crypto
• Forex
• Indices
• Stocks

Designed for traders who prefer clean charts with only the most important reference levels visible.

## Source Code

````pine
//@version=5
indicator("Opens [by Roman]", overlay=true)

// === SETTINGS ===
offsetBars  = input.int(20, "Line Length")
labelOffset = input.int(2, "Label Offset")
lineWidth   = input.int(1, "Line Width")

// === TOGGLES ===
showPDH = input.bool(true, "Show PDH")
showPDL = input.bool(true, "Show PDL")
showH4  = input.bool(true, "Show H4 Open")
showD   = input.bool(true, "Show Daily Open")
showW   = input.bool(true, "Show Weekly Open")
showM   = input.bool(true, "Show Monthly Open")
showY   = input.bool(true, "Show Yearly Open")

// === COLORS ===
pdhColor = input.color(color.green, "PDH Color")
pdlColor = input.color(color.green, "PDL Color")

h4Color  = input.color(color.black, "H4 Open Color")
dColor   = input.color(color.black, "Daily Open Color")
wColor   = input.color(color.black, "Weekly Open Color")
mColor   = input.color(color.black, "Monthly Open Color")
yColor   = input.color(color.black, "Yearly Open Color")

// === LEVELS ===
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

h4Open      = request.security(syminfo.tickerid, "240", open)
dailyOpen   = request.security(syminfo.tickerid, "D", open)
weeklyOpen  = request.security(syminfo.tickerid, "W", open)
monthlyOpen = request.security(syminfo.tickerid, "M", open)
yearlyOpen  = request.security(syminfo.tickerid, "12M", open)

// === FUNCTION ===
drawLevel(level, textLabel, levelColor) =>
    line.new(
         x1 = bar_index,
         y1 = level,
         x2 = bar_index + offsetBars,
         y2 = level,
         color = levelColor,
         width = lineWidth
     )

    label.new(
         x = bar_index + offsetBars + labelOffset,
         y = level,
         text = textLabel,
         style = label.style_none,
         textcolor = levelColor,
         size = size.small
     )

// === DRAW ONLY ON LAST BAR ===
if barstate.islast

    if showPDH
        drawLevel(pdh, "PDH", pdhColor)

    if showPDL
        drawLevel(pdl, "PDL", pdlColor)

    if showH4
        drawLevel(h4Open, "H4", h4Color)

    if showD
        drawLevel(dailyOpen, "D", dColor)

    if showW
        drawLevel(weeklyOpen, "W", wColor)

    if showM
        drawLevel(monthlyOpen, "M", mColor)

    if showY
        drawLevel(yearlyOpen, "Y", yColor)
````

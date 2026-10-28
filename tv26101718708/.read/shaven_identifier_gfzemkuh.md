# Shaven Identifier

- url: https://www.tradingview.com/script/gfZEmKUh-Shaven-Identifier/
- type: indicator
- pine_id: PUB;e7b2693cdbc44e5d9aa43c66284f2f2f
- version: 2.0

## Description

Shaven Identifier is a price-action tool designed to highlight "shaven" candles—specifically bullish candles with no bottom wick and bearish candles with no top wick. These formations often represent periods of strong, immediate conviction where the market moves decisively in one direction from the moment the candle opens.

[b]Core Concept[/b]
In standard Japanese Candlestick theory, these are often referred to as Shaven Bottom (bullish) or Shaven Head (bearish) candles. They indicate that:

[b]Bullish (No Bottom Wick):[/b] Buyers were so aggressive that the price never dipped below the opening price.
[b]Bearish (No Top Wick):[/b] Sellers were so aggressive that the price never rose above the opening price.

[b]Key Features[/b]
[b]Momentum Markers:[/b] The script places a triangle below bullish signals and above bearish signals to provide immediate visual feedback on candle close.
[b]Level Extensions:[/b] It draws horizontal lines from the "flat" side of the candle (the Open). These levels often act as "hidden" support or resistance, as they represent the exact price where one side of the market took total control.
[b]Customizable Duration:[/b] You can control how many bars the horizontal levels extend across the chart, allowing you to see how price reacts to these levels in the near future.

[b]How to Use It[/b]
[b]Trend Confirmation:[/b] Seeing multiple "No Wick" candles in the direction of a trend can signal high-momentum continuation.
[b]Support & Resistance:[/b] The horizontal lines extended from these candles can serve as targets or areas to watch for potential price rejections.
[b]Entry Signal:[/b] Some traders use these as confirmation for entries, as they show a lack of hesitation from the dominant side of the market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Marubozu Detection", overlay = true, max_lines_count = 500)

// --- Group Name: Style ---
bullColor  = input.color(#089981, "Bullish Marker", group = "Style", tooltip = "Color for candles with no bottom wick")
bearColor  = input.color(#f23645, "Bearish Marker", group = "Style", tooltip = "Color for candles with no top wick")
lineColor  = input.color(#ff9800, "Level Line", group = "Style", tooltip = "Color for the horizontal extension lines")

// --- Group Name: Extension Settings ---
untilTapped = input.bool(true, "Extend Until Tapped", group = "Extension Settings", tooltip = "If true, lines extend until price touches them. If false, they use fixed length.")
lineLength  = input.int(10, "Fixed Line Length", minval = 1, group = "Extension Settings", tooltip = "Number of bars the horizontal line extends if 'Extend Until Tapped' is disabled.")

// --- Group Name: Multi-Timeframe Settings ---
useMTF      = input.bool(true, "Enable MTF Signals", group = "Multi-Timeframe Settings")
tfInput     = input.timeframe("60", "Higher Timeframe", group = "Multi-Timeframe Settings")
htfBullCol  = input.color(color.new(#00bcd4, 0), "HTF Bullish Color", group = "Multi-Timeframe Settings")
htfBearCol  = input.color(color.new(#e91e63, 0), "HTF Bearish Color", group = "Multi-Timeframe Settings")

// --- Core Logic ---
// Bullish: Green candle and Open is the Low (no bottom wick)
isNoBottomWick = close > open and open == low
// Bearish: Red candle and Open is the High (no top wick)
isNoTopWick    = close < open and open == high

// --- MTF Logic ---
// We fetch the detection status from the HTF. 
// We use [1] to ensure we only get confirmed (closed) HTF candle data to prevent repainting.
[htfBull, htfBear] = request.security(syminfo.tickerid, tfInput, [isNoBottomWick[1], isNoTopWick[1]], lookahead = barmerge.lookahead_on)

// Identify the exact bar where the HTF candle closed on the LTF chart
htfChange = ta.change(time(tfInput)) != 0
showHTFBull = useMTF and htfBull and htfChange
showHTFBear = useMTF and htfBear and htfChange

// --- Visual Elements: Shapes ---
// Current Timeframe Signals (Triangles)
plotshape(isNoBottomWick, "No Bottom Wick", shape.triangleup, location.belowbar, bullColor, size = size.small)
plotshape(isNoTopWick, "No Top Wick", shape.triangledown, location.abovebar, bearColor, size = size.small)

// Higher Timeframe Signals (Diamonds with Labels)
plotshape(showHTFBull, "HTF No Bottom Wick", shape.diamond, location.belowbar, htfBullCol, size = size.small, text = "HTF", textcolor = htfBullCol)
plotshape(showHTFBear, "HTF No Top Wick", shape.diamond, location.abovebar, htfBearCol, size = size.small, text = "HTF", textcolor = htfBearCol)

// --- Visual Elements: Lines ---
var line[] activeLines = array.new_line()
var bool[] isBullLine  = array.new_bool()

// Add new lines for current timeframe signals
if isNoBottomWick
    newLine = line.new(bar_index, open, bar_index + (untilTapped ? 1 : lineLength), open, color = lineColor)
    if untilTapped
        array.push(activeLines, newLine)
        array.push(isBullLine, true)

if isNoTopWick
    newLine = line.new(bar_index, open, bar_index + (untilTapped ? 1 : lineLength), open, color = lineColor)
    if untilTapped
        array.push(activeLines, newLine)
        array.push(isBullLine, false)

// Manage "Extend Until Tapped" logic
if untilTapped and array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        l    = array.get(activeLines, i)
        y    = line.get_y1(l)
        bull = array.get(isBullLine, i)
        
        // Check if price touched the level (excluding the signal bar itself)
        bool touched = bull ? (low <= y and bar_index > line.get_x1(l)) : (high >= y and bar_index > line.get_x1(l))
        
        if touched
            line.set_x2(l, bar_index)
            array.remove(activeLines, i)
            array.remove(isBullLine, i)
        else
            line.set_x2(l, bar_index)

// --- Alerts ---
alertcondition(isNoBottomWick, "Bullish No-Wick Detected", "Bullish signal: No bottom wick at {{open}}")
alertcondition(isNoTopWick, "Bearish No-Wick Detected", "Bearish signal: No top wick at {{open}}")
alertcondition(showHTFBull, "HTF Bullish No-Wick", "HTF Bullish signal detected on {{tfInput}} timeframe")
alertcondition(showHTFBear, "HTF Bearish No-Wick", "HTF Bearish signal detected on {{tfInput}} timeframe")
````

# Previous Day Breakout Indicator

- url: https://www.tradingview.com/script/s0waCNcx-previous-day-breakout-indicator/
- type: indicator
- pine_id: PUB;567716d2428348c4a7deb3a2bb19891b
- version: 1.0

## Description

Strategy Breakdown
1.Previous Day Levels: The strategy uses request.security to look up the previous day's high and low prices.
2.Entry Conditions: To trigger an entry, the strategy checks if the current 5-minute bar and the previous 5-minute bar have both closed beyond the previous day's level (either above the high or below the low). To ensure we only enter precisely on the second bar, we check that the bar 2 bars ago did not close beyond the level.
3.Risk Management: Once in a position, the strategy relies on strategy.exit, utilizing the profit and loss parameters which accept points/ticks.
4.Visuals: The previous day's high and low are plotted on your chart for easy visual reference.
I've tightened the logic in the editor to guarantee that the strategy only looks at the previous day's levels and that the breakout explicitly originates from inside the previous day's range.

The entry condition now strictly requires:

1.The candle 2 bars ago was inside the previous day's range (meaning the breakout is fresh).
2.The previous candle (Bar 1) broke out and closed beyond the Previous Day High/Low.
3.The current candle (Bar 2) also closed beyond the Previous Day High/Low.
The strategy doesn't look at any other levels, support/resistance, or indicators.
What I added:
Projected Daily Candle: The script now constructs a visual representation of the Previous Day's candle (complete with the high/low wicks and the open/close body) and projects it to the right of your current price action.
It updates dynamically on the very last bar.
You can control exactly how far ahead it gets drawn via the "Candle Projection Offset (Bars)" input in the settings.
Continuous Levels: The Previous Day High and Low are continuously plotted as solid lines across the chart so you always know where those exact levels sit.
Entry Signals: Since this is now an indicator and not a strategy, I added plotshape() triangles to visualize the exact moments when your 2-bar breakout entry logic fires. Green triangles appear below the bar for Long setups, and red triangles appear above the bar for Short setups.
What's Changed:
1.Support & Resistance Zones: Instead of basic continuous lines, the Previous Day High and Low are now drawn as gray horizontal boxes spanning from the start of the current day extending out into the future, creating support and resistance "zones".
2.Text Labels: I added the Resistance (PDH) and Support (PDL) text labels directly above and below their respective zones, matching the image.
3.Midpoint Dashed Line: A dashed gray line now automatically calculates the exact center between the high and low (pdH + pdL) / 2 and runs horizontally through the entire daily range.
2.Candle Body Box: Instead of a thick line, the body of the projected candle is now constructed using a box with the text "PD" directly in the center, and the wick is a single vertical line running through it.
Now, the indicator will print a signal any time the price crosses and closes beyond either level for two consecutive bars, regardless of direction.

Specifically:

Long Signals (Green Triangle Up): Trigger if price breaks and holds above the Previous Day High OR if price breaks and holds above the Previous Day Low (e.g., crossing back up into the daily range).
Short Signals (Red Triangle Down): Trigger if price breaks and holds below the Previous Day Low OR if price breaks and holds below the Previous Day High (e.g., crossing back down into the daily range, as you highlighted with the red arrow in your image).
This effectively allows you to trade both the true breakouts and the fakeouts/reversions back inside the range! Check out the chart and let me know if those signals align perfectly with what you had in mind.
How it works now:
I added a new setting in the indicator's input menu called "Signal on Bar #". You can now choose exactly how many consecutive closes must happen beyond the line before the triangle signal prints.

Set to 1: The signal triggers immediately on the very first candle that closes outside the Previous Day High/Low.
Set to 2: (Your original request) The signal waits for two consecutive candles to close outside the level.
Set to 3 or 4: The script demands even more confirmation, waiting for 3 or 4 consecutive candles to close beyond the level without dipping back across it.
If the price dips back inside the range before your chosen number of bars completes, the count resets, preventing false signals. You can tweak this setting right from the gear icon to see how it filters the trades on your chart!

## Source Code

````pine
//@version=6
indicator("Previous Day Breakout Indicator", overlay = true)

// --- Inputs ---
var string G_VIS = "Visual Settings"
int projectionOffset = input.int(10, "Candle Projection Offset (Bars)", minval = 1, tooltip = "How many bars into the future to draw the previous day's candle", group = G_VIS)

var string G_SIG = "Signal Settings"
int signalBar = input.int(2, "Signal on Bar #", minval = 1, maxval = 4, tooltip = "Which bar after the breakout should trigger the signal (1 = immediate, 2 = second bar, etc.)", group = G_SIG)

// --- Core Logic ---
// Get previous day's open, high, low, and close
[pdO, pdH, pdL, pdC] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
float pdMid = (pdH + pdL) / 2

// Breakouts of PDH (Check if the lowest/highest close over the last 'N' bars is beyond the level, and the bar before that was inside)
bool breakAbovePDH = ta.lowest(close, signalBar) > pdH and close[signalBar] <= pdH
bool breakBelowPDH = ta.highest(close, signalBar) < pdH and close[signalBar] >= pdH

// Breakouts of PDL
bool breakAbovePDL = ta.lowest(close, signalBar) > pdL and close[signalBar] <= pdL
bool breakBelowPDL = ta.highest(close, signalBar) < pdL and close[signalBar] >= pdL

bool longEntry  = breakAbovePDH or breakAbovePDL
bool shortEntry = breakBelowPDH or breakBelowPDL

// --- Visual Elements ---
// Plot Entry Signals
plotshape(longEntry, "Long Entry", shape.triangleup, location.belowbar, color.new(#089981, 0), size = size.small)
plotshape(shortEntry, "Short Entry", shape.triangledown, location.abovebar, color.new(#f23645, 0), size = size.small)

// --- Projected Previous Day Candle & Levels ---
var line wickLine = na
var box bodyBox = na
var line midLine = na
var box resBox = na
var box supBox = na
var label resLabel = na
var label supLabel = na

// Find the start of the current day to draw the levels from
var int startOfDayBar = na
if time("D") != time("D")[1]
    startOfDayBar := bar_index

if barstate.islast
    // Determine candle color based on whether it was a bullish or bearish day
    color candleColor = pdC >= pdO ? color.new(#089981, 50) : color.new(#f23645, 50)
    color borderColor = pdC >= pdO ? #089981 : #f23645
    
    // Clean up previous drawings
    if not na(wickLine)
        line.delete(wickLine)
    if not na(bodyBox)
        box.delete(bodyBox)
    if not na(midLine)
        line.delete(midLine)
    if not na(resBox)
        box.delete(resBox)
    if not na(supBox)
        box.delete(supBox)
    if not na(resLabel)
        label.delete(resLabel)
    if not na(supLabel)
        label.delete(supLabel)
        
    // Calculate the future bar index for the projection
    int futureBarIndex = bar_index + projectionOffset
    int leftIndex = na(startOfDayBar) ? bar_index - 10 : startOfDayBar
    int rightIndex = futureBarIndex + 5
    
    // Draw horizontal resistance and support boxes (simulating the thin zones in the image)
    float zoneHeight = syminfo.mintick * 5 // adjust thickness
    resBox := box.new(left = leftIndex, top = pdH + zoneHeight, right = rightIndex, bottom = pdH - zoneHeight, border_color = color.gray, bgcolor = color.new(color.gray, 90))
    supBox := box.new(left = leftIndex, top = pdL + zoneHeight, right = rightIndex, bottom = pdL - zoneHeight, border_color = color.gray, bgcolor = color.new(color.gray, 90))
    
    // Labels for Support/Resistance
    int labelIndex = math.round((leftIndex + futureBarIndex) / 2)
    resLabel := label.new(x = labelIndex, y = pdH + zoneHeight, text = "Resistance (PDH)", style = label.style_none, textcolor = color.black, size = size.small)
    supLabel := label.new(x = labelIndex, y = pdL - zoneHeight, text = "Support (PDL)", style = label.style_none, textcolor = color.black, size = size.small)

    // Draw the midpoint dashed line
    midLine := line.new(x1 = leftIndex, y1 = pdMid, x2 = rightIndex, y2 = pdMid, color = color.gray, style = line.style_dashed, width = 1)
    
    // Draw the vertical wick
    wickLine := line.new(x1 = futureBarIndex, y1 = pdH, x2 = futureBarIndex, y2 = pdL, color = borderColor, width = 1)
    
    // Draw the body as a box with text "PD"
    float bodyTop = math.max(pdO, pdC)
    float bodyBot = math.min(pdO, pdC)
    if bodyTop == bodyBot
        bodyTop += syminfo.mintick
        bodyBot -= syminfo.mintick
        
    int boxWidth = math.max(1, math.round(projectionOffset / 4))
    bodyBox := box.new(left = futureBarIndex - boxWidth, top = bodyTop, right = futureBarIndex + boxWidth, bottom = bodyBot, border_color = borderColor, bgcolor = candleColor, text = "PD", text_color = color.black, text_size = size.small)
````

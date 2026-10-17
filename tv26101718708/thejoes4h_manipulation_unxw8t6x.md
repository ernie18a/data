# TheJOES-4H Manipulation

- url: https://www.tradingview.com/script/UNxW8T6X-TheJOES-4H-Manipulation/
- type: indicator
- pine_id: PUB;ee33aff338c3461285e6e0fa00e26ca0
- version: 1.0

## Description

This is not a save all indictor but helps traders who use 4hr time frame

## Source Code

````pine
//@version=6
indicator("4H Manipulation Engulfing", overlay = true, max_labels_count = 500)

// =============================================================================
//  4H Manipulation Engulfing  (Sweep & Reclaim / Liquidity-Grab Engulf)
//  Based on the pattern taught by Tom Crampton.
//
//  BULLISH: current candle wicks BELOW the prior candle's low (grabs sell-side
//           liquidity), then CLOSES back above it (engulfs to the upside).
//  BEARISH: current candle wicks ABOVE the prior candle's high (grabs buy-side
//           liquidity), then CLOSES back below it (engulfs to the downside).
//  Demoed on the 4H, but works on any timeframe (optional 4H-only filter).
// =============================================================================

// ---------------------------------------------------------------- INPUTS -----
grpD = "Detection"
showBull   = input.bool(true,  "Show Bullish signals",  group = grpD)
showBear   = input.bool(true,  "Show Bearish signals",  group = grpD)

engulfMode = input.string("Full candle (close beyond prior high/low)", "Engulf strength", options = ["Full candle (close beyond prior high/low)", "Body only (close beyond prior open)"], group = grpD, tooltip = "Full candle = stricter; close must clear the entire previous candle. Body only = classic engulfing (close clears the prior body).")

reqOppColor = input.bool(true, "Require opposite-colour prior candle", group = grpD, tooltip = "Bullish needs a prior DOWN candle; bearish needs a prior UP candle.")

only4H     = input.bool(false, "Only show on 4H timeframe", group = grpD, tooltip = "When on, signals only appear when the chart timeframe is 240 minutes.")

grpS = "Style"
bullCol   = input.color(color.new(#26a69a, 0), "Bullish colour", group = grpS)
bearCol   = input.color(color.new(#ef5350, 0), "Bearish colour", group = grpS)
labelText = input.bool(true,  "Show text labels", group = grpS)
markWick  = input.bool(true,  "Mark the swept level", group = grpS, tooltip = "Draws a small line at the previous high/low that was manipulated.")

// ------------------------------------------------------------ TF FILTER ------
tfOk = not only4H or timeframe.period == "240"

// --------------------------------------------------------------- LOGIC -------
priorDown = close[1] < open[1]
priorUp   = close[1] > open[1]

sweptLow  = low  < low[1]
sweptHigh = high > high[1]

bodyMode  = engulfMode == "Body only (close beyond prior open)"
bullClose = bodyMode ? close > open[1] : close > high[1]
bearClose = bodyMode ? close < open[1] : close < low[1]

bullColorOk = not reqOppColor or priorDown
bearColorOk = not reqOppColor or priorUp

bullSignal = showBull and tfOk and sweptLow  and bullClose and close > open and bullColorOk
bearSignal = showBear and tfOk and sweptHigh and bearClose and close < open and bearColorOk

// ------------------------------------------------------------- PLOTTING ------
plotshape(bullSignal, title = "Bullish", style = shape.triangleup,   location = location.belowbar, color = bullCol, size = size.small)
plotshape(bearSignal, title = "Bearish", style = shape.triangledown, location = location.abovebar, color = bearCol, size = size.small)

if labelText and bullSignal
    label.new(bar_index, low, "Bull\nManip", yloc = yloc.belowbar, style = label.style_none, textcolor = bullCol, size = size.small)

if labelText and bearSignal
    label.new(bar_index, high, "Bear\nManip", yloc = yloc.abovebar, style = label.style_none, textcolor = bearCol, size = size.small)

if markWick and bullSignal
    line.new(bar_index - 1, low[1], bar_index, low[1], color = bullCol, style = line.style_dotted, width = 1)
if markWick and bearSignal
    line.new(bar_index - 1, high[1], bar_index, high[1], color = bearCol, style = line.style_dotted, width = 1)

// --------------------------------------------------------------- ALERTS ------
alertcondition(bullSignal, "Bullish Manipulation Engulf", "Bullish manipulation engulfing candle detected")
alertcondition(bearSignal, "Bearish Manipulation Engulf", "Bearish manipulation engulfing candle detected")

if bullSignal
    alert("Bullish Manipulation Engulf on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
if bearSignal
    alert("Bearish Manipulation Engulf on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````

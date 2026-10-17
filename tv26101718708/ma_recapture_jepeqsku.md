# MA Recapture

- url: https://www.tradingview.com/script/JePEqskU-MA-Recapture/
- type: indicator
- pine_id: PUB;d62248aafda24fc6be51f856ac4a502d
- version: 1.0

## Description

MA Recapture
tradingview says it needs more words so here it is

## Source Code

````pine
// @version=5
indicator("MA Recapture", overlay=true)

// --- Inputs ---
maLength   = input.int(30, title="MA Length")
signalType = input.string("Both", title="Signals to Show", options=["Both", "Bullish Only", "Bearish Only"])
posInput   = input.string("Outside", title="Marker Position", options=["Outside", "Above Bar", "Below Bar"])

// Color Inputs
bullColor  = input.color(#00FFFF, title="Bullish Color")
bearColor  = input.color(#FF00FF, title="Bearish Color")
maVisible  = input.bool(true, title="Show MA Line?")

// --- Calculation ---
ma = ta.sma(close, maLength)

// Define conditions
isBull  = close[1] < ma[1] and close > ma
isBear  = close[1] > ma[1] and close < ma

// Filter Logic
showBull = (signalType == "Both" or signalType == "Bullish Only") and isBull
showBear = (signalType == "Both" or signalType == "Bearish Only") and isBear

// --- Rendering Logic ---
// We do this without a custom function to avoid any type-inference issues with yloc
if showBull
    // Determine Location for Bull Arrow
    bullLoc = posInput == "Above Bar" ? yloc.abovebar : yloc.belowbar
    label.new(bar_index, na, text="▲", yloc=bullLoc, style=label.style_none, textcolor=bullColor, size=size.huge)

if showBear
    // Determine Location for Bear Arrow
    // If "Outside", Bear goes Above. Otherwise, follow the user input.
    bearLoc = posInput == "Outside" ? yloc.abovebar : (posInput == "Above Bar" ? yloc.abovebar : yloc.belowbar)
    label.new(bar_index, na, text="▼", yloc=bearLoc, style=label.style_none, textcolor=bearColor, size=size.huge)

// --- MA Plot ---
plot(maVisible ? ma : na, color=color.new(color.gray, 50), title="MA Line")
````

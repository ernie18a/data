# Sandwich Candle Pattern (Doji Between Momentum Candles) 

- url: https://www.tradingview.com/script/Vqo4uaVs-Sandwich-Candle-Pattern-Doji-Between-Momentum-Candles/
- type: indicator
- pine_id: PUB;6ee097214096482a9feb9e615b754414
- version: 2.0

## Description

Sandwich Candle Pattern (Doji Between Momentum Candles)

## Source Code

````pine
//@version=6
indicator("Sandwich Candle Pattern (Doji Between Momentum Candles)", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// INPUTS
// ============================================================
grp1 = "Candle Classification"
rangeLen        = input.int(14, "Average Range Lookback (bars)", minval=1, group=grp1,
     tooltip="Number of bars used to calculate the average candle range for relative sizing.")
momentumBodyPct = input.float(0.60, "Min Body/Range Ratio for Momentum Candle", minval=0.1, maxval=1.0, step=0.05, group=grp1,
     tooltip="A candle qualifies as a 'momentum' candle if its body is at least this % of its own high-low range.")
dojiBodyPct     = input.float(0.15, "Max Body/Range Ratio for Doji Candle", minval=0.01, maxval=0.5, step=0.01, group=grp1,
     tooltip="A candle qualifies as a 'doji' if its body is at most this % of its own high-low range.")
useRelativeSize = input.bool(true, "Require Momentum Candles Range >= Average Range", group=grp1,
     tooltip="If enabled, momentum candles must also have a range >= the average range over the lookback period (filters out small choppy candles).")

grp2 = "Pattern Rules"
directionMode = input.string("Any", "Momentum Candle Direction Requirement", options=["Any", "Same Direction", "Opposite Direction"], group=grp2,
     tooltip="Any = no direction filter. Same Direction = both momentum candles bullish or both bearish. Opposite Direction = one bullish, one bearish (reversal-style sandwich).")

grp3 = "Visuals"
showLabels   = input.bool(true, "Show Labels", group=grp3)
bullColor    = input.color(color.new(color.teal, 0), "Bullish Sandwich Color", group=grp3)
bearColor    = input.color(color.new(color.red, 0), "Bearish Sandwich Color", group=grp3)
neutralColor = input.color(color.new(color.orange, 0), "Neutral/Mixed Sandwich Color", group=grp3)

grp4 = "Wick Line & Entry Text"
showWickLine  = input.bool(true, "Draw Line on Doji Wick", group=grp4)
wickLineWidth = input.int(2, "Wick Line Width", minval=1, maxval=5, group=grp4)
showEntryText = input.bool(true, "Show 'Entry' Text", group=grp4)
entryTextSize = input.string(size.tiny, "Entry Text Size", options=[size.tiny, size.small, size.normal], group=grp4)

// ============================================================
// CORE CALCULATIONS
// ============================================================
body  = math.abs(close - open)
rng   = high - low
avgRng = ta.sma(rng, rangeLen)

// Safe ratio (avoid division by zero on flat candles)
bodyRatio = rng > 0 ? body / rng : 0.0

isDoji = bodyRatio <= dojiBodyPct

isMomentumRaw = bodyRatio >= momentumBodyPct
isMomentum = useRelativeSize ? (isMomentumRaw and rng >= avgRng) : isMomentumRaw

isBullCandle = close > open
isBearCandle = close < open

// ============================================================
// PATTERN DETECTION
// candle[2] = first momentum candle, candle[1] = doji, candle[0] = second momentum candle
// Pattern confirms on the current bar (candle[0]) closing, marker is drawn on the doji bar (bar[1])
// ============================================================
firstMomentum  = isMomentum[2]
middleDoji     = isDoji[1]
secondMomentum = isMomentum

firstBull  = isBullCandle[2]
firstBear  = isBearCandle[2]
secondBull = isBullCandle
secondBear = isBearCandle

directionOK = switch directionMode
    "Any"                => true
    "Same Direction"     => (firstBull and secondBull) or (firstBear and secondBear)
    "Opposite Direction" => (firstBull and secondBear) or (firstBear and secondBull)
    => true

sandwichPattern = firstMomentum and middleDoji and secondMomentum and directionOK

// Classify pattern type for coloring
bullishSandwich = sandwichPattern and firstBull and secondBull
bearishSandwich = sandwichPattern and firstBear and secondBear
mixedSandwich   = sandwichPattern and not bullishSandwich and not bearishSandwich

// ============================================================
// PLOTTING
// ============================================================
// Mark the doji (middle) candle using offset -1 since pattern confirms on bar 0
plotshape(bullishSandwich, title="Bullish Sandwich", location=location.belowbar, offset=-1,
     style=shape.triangleup, size=size.tiny, color=bullColor)

plotshape(bearishSandwich, title="Bearish Sandwich", location=location.abovebar, offset=-1,
     style=shape.triangledown, size=size.tiny, color=bearColor)

plotshape(mixedSandwich, title="Mixed/Neutral Sandwich", location=location.abovebar, offset=-1,
     style=shape.diamond, size=size.tiny, color=neutralColor)

if showLabels and sandwichPattern
    labelColor = bullishSandwich ? bullColor : bearishSandwich ? bearColor : neutralColor
    labelText  = bullishSandwich ? "Sandwich\n(Bull)" : bearishSandwich ? "Sandwich\n(Bear)" : "Sandwich"
    labelStyle = bearishSandwich ? label.style_label_down : label.style_label_up
    labelYloc  = bearishSandwich ? yloc.abovebar : yloc.belowbar
    label.new(bar_index[1], na, labelText, xloc.bar_index, labelYloc, labelColor,
         labelStyle, color.white, size.small)

// ============================================================
// WICK LINE + ENTRY TEXT ON THE DOJI CANDLE
// ============================================================
if sandwichPattern
    lineColor = bullishSandwich ? bullColor : bearishSandwich ? bearColor : neutralColor

    // Draw a vertical line spanning the full wick (high to low) of the doji bar
    if showWickLine
        line.new(bar_index[1], low[1], bar_index[1], high[1], xloc=xloc.bar_index,
             extend=extend.none, color=lineColor, width=wickLineWidth, style=line.style_solid)

    // Small "Entry" text placed just beyond the wick extreme
    if showEntryText
        entryPrice = bearishSandwich ? high[1] + (avgRng * 0.15) : low[1] - (avgRng * 0.15)
        entryStyle = bearishSandwich ? label.style_label_down : label.style_label_up
        entryYloc  = bearishSandwich ? yloc.price : yloc.price
        label.new(bar_index[1], entryPrice, "Entry", xloc.bar_index, entryYloc, color.new(color.white, 100),
             entryStyle, lineColor, entryTextSize)

// ============================================================
// ALERTS
// ============================================================
alertcondition(sandwichPattern, title="Sandwich Candle Detected", message="Sandwich candle pattern detected (doji between two momentum candles)")
alertcondition(bullishSandwich, title="Bullish Sandwich Detected", message="Bullish sandwich pattern: doji between two bullish momentum candles")
alertcondition(bearishSandwich, title="Bearish Sandwich Detected", message="Bearish sandwich pattern: doji between two bearish momentum candles")
````

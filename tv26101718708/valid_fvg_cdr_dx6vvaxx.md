# Valid FVG CDR

- url: https://www.tradingview.com/script/Dx6vVAXX-Valid-FVG-CDR/
- type: indicator
- pine_id: PUB;074d804336714b2d8d591cc4fb5bd3a0
- version: 1.0

## Description

Valid FVG CDR is a clean Fair Value Gap (FVG) indicator based on ICT / Smart Money Concepts.

Features:
• Detects valid Bullish and Bearish FVGs
• ATR-based minimum gap filter
• Removes fully mitigated FVGs automatically
• Fixed 20-candle display length
• Clean chart visualization
• Bullish FVG = Green
• Bearish FVG = Red
• Alert support for new FVG creation
• Works on all Forex pairs, Gold (XAUUSD), Indices and Crypto

This indicator is designed to highlight only meaningful Fair Value Gaps while reducing chart clutter.

## Source Code

````pine
//@version=6
indicator("Valid FVG (5 Candle Length)", overlay=true, max_boxes_count=500)

// ===== Inputs =====
fvgLength = input.int(5, "FVG Length", minval=1)
atrLen = input.int(14, "ATR Length")
atrMult = input.float(0.20, "Min FVG Size (ATR Multiplier)", step=0.05)

bullColor = input.color(color.new(color.green, 85), "Bullish FVG Color")
bearColor = input.color(color.new(color.red, 85), "Bearish FVG Color")

// ===== ATR Filter =====
atr = ta.atr(atrLen)
minGap = atr * atrMult

// ===== Arrays =====
var box[] bullBoxes = array.new_box()
var float[] bullBottoms = array.new_float()

var box[] bearBoxes = array.new_box()
var float[] bearTops = array.new_float()

// ======================================================
// BULLISH FVG
// ======================================================
bullFVG = low > high[2]
bullGap = low - high[2]

if bullFVG and bullGap >= minGap

    bullBox = box.new(
         left = bar_index - 2,
         top = low,
         right = bar_index + fvgLength,
         bottom = high[2],
         bgcolor = bullColor,
         border_color = color.green)

    array.push(bullBoxes, bullBox)
    array.push(bullBottoms, high[2])

// ======================================================
// BEARISH FVG
// ======================================================
bearFVG = high < low[2]
bearGap = low[2] - high

if bearFVG and bearGap >= minGap

    bearBox = box.new(
         left = bar_index - 2,
         top = low[2],
         right = bar_index + fvgLength,
         bottom = high,
         bgcolor = bearColor,
         border_color = color.red)

    array.push(bearBoxes, bearBox)
    array.push(bearTops, low[2])

// ======================================================
// DELETE FILLED BULLISH FVG
// ======================================================
bullCount = array.size(bullBoxes)

if bullCount > 0
    for i = bullCount - 1 to 0

        fvgBottom = array.get(bullBottoms, i)

        if low <= fvgBottom

            box.delete(array.get(bullBoxes, i))

            array.remove(bullBoxes, i)
            array.remove(bullBottoms, i)

// ======================================================
// DELETE FILLED BEARISH FVG
// ======================================================
bearCount = array.size(bearBoxes)

if bearCount > 0
    for i = bearCount - 1 to 0

        fvgTop = array.get(bearTops, i)

        if high >= fvgTop

            box.delete(array.get(bearBoxes, i))

            array.remove(bearBoxes, i)
            array.remove(bearTops, i)

// ======================================================
// ALERTS
// ======================================================
alertcondition(bullFVG and bullGap >= minGap,
     title="Bullish FVG",
     message="New Bullish FVG Created")

alertcondition(bearFVG and bearGap >= minGap,
     title="Bearish FVG",
     message="New Bearish FVG Created")
````

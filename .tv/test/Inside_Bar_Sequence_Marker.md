<!-- tradingview-pine-id: PUB;a223abec74b44f67bad036c096715387 -->
<!-- tradingviewscripts-format: 1 -->
# Inside Bar Sequence Marker

Source: https://www.tradingview.com/script/97jd1jJ8-MARK-Inside-Bars/

## Description

**Mother Bar Range — Inside Bar Sequence** is a simple price-action indicator designed to identify and highlight consecutive candles trading within the range of a Mother Bar.

Unlike traditional inside-bar indicators that compare each candle only to the candle immediately before it, this indicator tracks the **original Mother Bar's High and Low**.

Once an Inside Bar forms, the previous candle becomes the Mother Bar. Every following candle is highlighted as long as:

• Its High remains at or below the Mother Bar High
• Its Low remains at or above the Mother Bar Low

This makes it easy to identify extended periods of **price compression and consolidation**, even when there are multiple consecutive candles inside the same Mother Bar range.

The sequence ends when price trades outside the Mother Bar's range.

**Useful for identifying:**
• Inside Bar sequences
• Price compression
• Consolidation ranges
• Mother Bar structures
• Potential expansion/breakout setups

Works on all markets and timeframes.

---

## Source Code

````pine
//@version=6
indicator("Inside Bar Sequence Marker", overlay=true)

// Persistent mother bar levels
var float motherHigh = na
var float motherLow  = na
var bool inInsideSequence = false

// First inside bar compared with previous candle
firstInsideBar = high <= high[1] and low >= low[1]

// Start a new inside-bar sequence
if not inInsideSequence and firstInsideBar
    motherHigh := high[1]
    motherLow := low[1]
    inInsideSequence := true

// Check whether current candle remains inside original mother bar
insideMotherBar = inInsideSequence and high <= motherHigh and low >= motherLow

// End sequence when candle breaks mother bar range
if inInsideSequence and not insideMotherBar
    inInsideSequence := false
    motherHigh := na
    motherLow := na

// Mark EVERY candle inside the mother bar
barcolor(insideMotherBar ? color.yellow : na)

plotshape(
     insideMotherBar,
     title="Inside Bar",
     style=shape.circle,
     location=location.belowbar,
     color=color.yellow,
     size=size.tiny
)
````

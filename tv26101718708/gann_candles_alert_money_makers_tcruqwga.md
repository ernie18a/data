# Gann Candles Alert (Money Makers)

- url: https://www.tradingview.com/script/TCRUQwga-Gann-Candles-Alert-Money-Makers/
- type: indicator
- pine_id: PUB;584479115ce04ea482e346416cbed17e
- version: 1.0

## Description

This indicator identifies strong directional price movement based on consecutive market structure rather than only candle direction. Following one of W. D. Gann's strategies .

It detects sequences of candles forming:

Higher Highs and Higher Lows (bullish structure)
Lower Highs and Lower Lows (bearish structure)

Once a sequence reaches 7 or more candles, the indicator marks a key structural level:

Bullish sequence → horizontal level at the last candle’s low
Bearish sequence → horizontal level at the last candle’s high

The level dynamically updates as long as the sequence continues.

Entry Logic

An “Entry” signal is generated when price breaks the structure:

Break below bullish structure → short entry
Break above bearish structure → long entry

At the moment of entry:

The structure level is fixed and drawn between the sequence and the break candle
A Stop Loss (SL) level is plotted:
For short trades → SL at the sequence last candle’s high
For long trades → SL at the sequence last candle’s low
Features
Works on all timeframes
Uses structure (HH/HL & LH/LL) instead of candle color
Dynamic level tracking
Entry and alert conditions included
Visual SL placement based on price structure
Notes

This indicator is designed for educational and analytical purposes. It does not provide financial advice. Users should combine it with proper risk management and additional confirmation tools.

## Source Code

````pine
//@version=6
indicator("Gann Candles Alert (Money Makers)", overlay=true)

// Candle direction
bull = close > open
bear = close < open

// same color
sameBull = bull and bull[1]
sameBear = bear and bear[1]

// opposite color
bullFlip = bull and bear[1]
bearFlip = bear and bull[1]

// Bull logic
bullValid = (sameBull and high >= high[1] and low >= low[1]) or bullFlip

// Bear logic
bearValid = (sameBear and high <= high[1] and low <= low[1]) or bearFlip

// Counters
var int bullCount = 0
var int bearCount = 0

bullCount := bullValid ? bullCount + 1 : 0
bearCount := bearValid ? bearCount + 1 : 0

// Tracking
var line bullLine = na
var line bearLine = na
var line bullSLLine = na
var line bearSLLine = na

var float bullLevel = na
var float bearLevel = na

var float bullSL = na
var float bearSL = na

var int bullStartBar = na
var int bearStartBar = na

var bool bullActive = false
var bool bearActive = false

// === BULLISH SEQUENCE ===
if bullCount >= 7 and barstate.isconfirmed
    if not na(bullLine)
        line.delete(bullLine)
    
    bullLevel := low
    bullSL := high
    bullStartBar := bar_index
    bullActive := true

    bullLine := line.new(
        bar_index, bullLevel,
        bar_index + 1, bullLevel,
        color=color.green,
        width=2,
        extend=extend.right
    )

// === BEARISH SEQUENCE ===
if bearCount >= 7 and barstate.isconfirmed
    if not na(bearLine)
        line.delete(bearLine)
    
    bearLevel := high
    bearSL := low
    bearStartBar := bar_index
    bearActive := true

    bearLine := line.new(
        bar_index, bearLevel,
        bar_index + 1, bearLevel,
        color=color.red,
        width=2,
        extend=extend.right
    )

// === ENTRY CONDITIONS ===

// Bullish → break DOWN (short)
barsSinceBull = bar_index - bullStartBar

bullBreak = bullActive and not na(bullLevel) and close < bullLevel and barstate.isconfirmed and barsSinceBull <= 7

// Expire bullish setup
if bullActive and (bar_index - bullStartBar > 7)
    bullActive := false

if bullBreak
    label.new(bar_index, close, "Entry: " + str.tostring(close), style=label.style_label_down, color=color.red)

    // Redraw main level
    if not na(bullLine)
        line.delete(bullLine)
    
    line.new(bullStartBar, bullLevel, bar_index, bullLevel, color=color.green, width=1)

    // 🔥 Draw SL line (thin)
    bullSLLine := line.new(
        bullStartBar, bullSL,
        bar_index, bullSL,
        color=color.red,
        width=1
    )

    bullActive := false

// Bearish → break UP (long)
barsSinceBear = bar_index - bearStartBar

bearBreak = bearActive and not na(bearLevel) and close > bearLevel and barstate.isconfirmed and barsSinceBear <= 7

// Expire bearish setup
if bearActive and (bar_index - bearStartBar > 7)
    bearActive := false
    
if bearBreak
    label.new(bar_index, close, "Entry: " + str.tostring(close), style=label.style_label_up, color=color.green)

    if not na(bearLine)
        line.delete(bearLine)
    
    line.new(bearStartBar, bearLevel, bar_index, bearLevel, color=color.red, width=1)

    // 🔥 Draw SL line (thin)
    bearSLLine := line.new(
        bearStartBar, bearSL,
        bar_index, bearSL,
        color=color.red,
        width=1
    )

    bearActive := false

// === ALERTS ===
alertcondition(bullBreak or bearBreak, title="Entry", message="Break structure → Entry")


// Optional signal at 7
bullSignal = bullCount == 7 and barstate.isconfirmed
bearSignal = bearCount == 7 and barstate.isconfirmed

// === ALERTS FOR 7 CANDLES FORMATION ===
alertcondition(
    bullSignal or bearSignal,
    title="7 Structure Candles",
    message="7+ structure candles formed"
)

plotshape(bullSignal, location=location.belowbar,
     color=color.green, style=shape.labelup, text="Gann candles")

plotshape(bearSignal, location=location.abovebar,
     color=color.red, style=shape.labeldown, text="Gann candles")
````

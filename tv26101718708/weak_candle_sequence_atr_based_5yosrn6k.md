# Weak Candle Sequence (ATR Based)

- url: https://www.tradingview.com/script/5Yosrn6k-Weak-Candle-Sequence-ATR-Based/
- type: indicator
- pine_id: PUB;554dd5285cce48c2a6580236929dfdee
- version: 1.0

## Description

The **Weak Candle Sequence (ATR Based)** indicator identifies periods where price begins to lose momentum by detecting consecutive candles with unusually small bodies relative to ATR.

Instead of using a fixed candle size, the indicator compares each candle’s body to the market’s current volatility, making it adaptable across different markets and timeframes.

**How it works:**
- Measures candle body size against ATR.
- Highlights candles that fall below your chosen ATR threshold.
- Counts consecutive weak candles.
- Highlights the chart once the minimum number of weak candles has been reached.
- Optionally marks the beginning of the sequence with a **“Weak Run”** label.

**Customisable settings include:**
- ATR Length
- Maximum body size as a percentage of ATR
- Minimum number of consecutive weak candles
- Optional labels

The indicator is designed to make periods of **price compression, hesitation and weakening momentum easier to identify objectively**, removing some of the guesswork from visually judging candle strength.

## Source Code

````pine
//@version=6
indicator("Weak Candle Sequence (ATR Based)", overlay=true)

// === INPUTS ===
atrLength      = input.int(14, "ATR Length")
threshold      = input.float(0.10, "Max Body Size (% of ATR)", step=0.01)
minCandles     = input.int(4, "Min Weak Candles in a Row", minval=1)
showLabels     = input.bool(true, "Show Label")

// === CALCULATIONS ===
atrValue = ta.atr(atrLength)

// Candle body size
bodySize = math.abs(close - open)

// Weak candle condition
isWeak = bodySize <= (atrValue * threshold)

// Count consecutive weak candles
var int weakCount = 0
weakCount := isWeak ? weakCount + 1 : 0

// Condition met
sequenceMet = weakCount >= minCandles

// === VISUALS ===

// Highlight background
bgcolor(sequenceMet ? color.new(color.yellow, 85) : na)

// Optional label on first occurrence
plotshape(
    sequenceMet and not sequenceMet[1],
    title="Weak Sequence Start",
    location=location.abovebar,
    color=color.yellow,
    style=shape.labeldown,
    text="Weak Run"
)

// Plot weak candles (optional visual)
barcolor(isWeak ? color.gray : na)
````

# BigCandleSecondBeforeReversalEqualLevels

- url: https://www.tradingview.com/script/RTV5ZIjT-bigcandlesecondbeforereversalequallevels/
- type: indicator
- pine_id: PUB;db0fe3ed44854d6ab5293feedf86d0b8
- version: 1.0

## Description

# Big Candle + Reversal Series + Equal Levels

This indicator combines three different tools into one script, helping traders identify important market structures, momentum candles, and potential support/resistance levels.

### Features

#### 1. Big Candle Detection

The indicator identifies candles whose size exceeds the average candle size by a user-defined multiplier.

* Average candle size period is configurable.
* Multiplier is configurable.
* Large candles are highlighted directly on the chart.
* Useful for spotting impulsive moves, liquidity sweeps, and strong momentum.

---

#### 2. Second Candle Before Reversal

The indicator detects reversal sequences after a series of candles moving in the same direction.

Rules:

* A bullish series must contain at least the specified number of consecutive bullish candles.
* When a bearish candle appears after the bullish series, the script marks the second bullish candle before the reversal candle.
* The same logic applies in reverse for bearish series followed by a bullish candle.

This can help identify areas where trends often begin to accelerate before a local reversal.

---

#### 3. Equal Levels Detection

The script automatically detects price levels formed by:

* Equal Highs (High = High)
* Equal Lows (Low = Low)
* Mirror Levels (High ≈ Low)

A user-defined tolerance allows detection of levels even when prices differ by a small number of points.

Additional settings:

* Maximum distance between candles used to form a level.
* Tolerance in points.
* Horizontal projection length.
* Maximum number of levels displayed.

Levels are projected only to the right side of the chart, making the original candles visible.

---

### Inputs

* Average Candle Period
* Big Candle Multiplier
* Minimum Series Length
* Maximum Distance Between Candles
* Level Tolerance
* Level Projection Length
* Maximum Number of Levels

---

### Intended Use

This indicator is designed for traders who combine:

* Market structure analysis
* Support and resistance trading
* Liquidity concepts
* Price action
* Reversal and continuation setups

All three components work together to highlight significant price areas and important candle formations directly on the chart.

## Source Code

````pine
//@version=6
indicator("Big Candle + Second Before Reversal + Equal Levels", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// НАСТРОЙКИ BIG CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
length = input.int(20, "Период среднего размера свечи", minval=1)
multiplier = input.float(3.0, "Во сколько раз свеча больше среднего", minval=0.1, step=0.1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// НАСТРОЙКИ СЕРИИ СВЕЧЕЙ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
minSeriesLength = input.int(3, "Минимальная длина серии", minval=3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// НАСТРОЙКИ УРОВНЕЙ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lookbackBars = input.int(5, "Максимальное расстояние между свечами для уровня", minval=1)
tolerancePoints = input.int(10, "Допуск уровня в пунктах", minval=0)
lineLengthBars = input.int(100, "Длина уровня вправо в свечах", minval=1)
maxLevels = input.int(100, "Максимум уровней на графике", minval=1)

highHighColor = input.color(color.red, "Уровень High = High")
lowLowColor = input.color(color.lime, "Уровень Low = Low")
mirrorColor = input.color(color.orange, "Зеркальный уровень")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BIG CANDLE FINDER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
candleSize = high - low
avgCandleSize = ta.sma(candleSize, length)

bigCandle = candleSize > avgCandleSize * multiplier

barcolor(bigCandle ? color.orange : na)

plotshape(
     bigCandle,
     title="Большая свеча",
     style=shape.diamond,
     location=location.abovebar,
     color=color.orange,
     size=size.small,
     text="BIG",
     textcolor=color.white
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECOND CANDLE BEFORE REVERSAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isGreen = close > open
isRed   = close < open

var int greenCount = 0
var int redCount = 0

greenCount := isGreen ? greenCount[1] + 1 : 0
redCount   := isRed   ? redCount[1] + 1   : 0

greenSeriesToRed = isRed and greenCount[1] >= minSeriesLength
redSeriesToGreen = isGreen and redCount[1] >= minSeriesLength

plotshape(
     greenSeriesToRed,
     title="Вторая зеленая перед красной",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="2",
     textcolor=color.white,
     size=size.small,
     offset=-2
)

plotshape(
     redSeriesToGreen,
     title="Вторая красная перед зеленой",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="2",
     textcolor=color.white,
     size=size.small,
     offset=-2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EQUAL CANDLE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tolerance = tolerancePoints * syminfo.mintick

var line[] levels = array.new_line()

createLevel(int startIndex, float price, color levelColor) =>
    newLine = line.new(
         x1=startIndex,
         y1=price,
         x2=startIndex + lineLengthBars,
         y2=price,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=levelColor,
         width=1
     )

    array.push(levels, newLine)

    if array.size(levels) > maxLevels
        oldLine = array.shift(levels)
        line.delete(oldLine)

for i = 1 to lookbackBars

    // High = High
    if math.abs(high - high[i]) <= tolerance
        levelPrice = (high + high[i]) / 2
        startIndex = bar_index - i
        createLevel(startIndex, levelPrice, highHighColor)

    // Low = Low
    if math.abs(low - low[i]) <= tolerance
        levelPrice = (low + low[i]) / 2
        startIndex = bar_index - i
        createLevel(startIndex, levelPrice, lowLowColor)

    // Зеркальный уровень: текущий High ≈ прошлый Low
    if math.abs(high - low[i]) <= tolerance
        levelPrice = (high + low[i]) / 2
        startIndex = bar_index - i
        createLevel(startIndex, levelPrice, mirrorColor)

    // Зеркальный уровень: текущий Low ≈ прошлый High
    if math.abs(low - high[i]) <= tolerance
        levelPrice = (low + high[i]) / 2
        startIndex = bar_index - i
        createLevel(startIndex, levelPrice, mirrorColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// АЛЕРТЫ
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bigCandle, title="Большая свеча", message="Обнаружена большая свеча")

alertcondition(
     greenSeriesToRed,
     title="Вторая зеленая перед красной",
     message="После серии зеленых свечей появилась красная. Отмечена вторая зеленая свеча перед ней."
)

alertcondition(
     redSeriesToGreen,
     title="Вторая красная перед зеленой",
     message="После серии красных свечей появилась зеленая. Отмечена вторая красная свеча перед ней."
)
````

# Time Intervals (Bars)

- url: https://www.tradingview.com/script/12MCbmNa-Time-Intervals-Bars/
- type: indicator
- pine_id: PUB;703383f124f140729a4b3c665a04f6f9
- version: 4.0

## Description

[b]Bar Cycle Vertical Lines[/b]

This indicator provides a simple but powerful way to segment price action into consistent, repeatable intervals based on a user-defined number of bars. Each vertical line marks the start of a new cycle, allowing traders to visually break the chart into uniform “market rhythm blocks.”

Unlike time-based segmentation, this approach is fully bar-driven, meaning each cycle represents an equal amount of market interaction regardless of time or session conditions.

[b]How It Works[/b]

• The user selects a fixed number of bars per cycle
• A vertical line is drawn every N bars
• These lines divide price action into equal structural segments

This creates a clean visual framework for analyzing repeating behavior in price.

[b]How It Can Be Used[/b]

This tool is especially useful for evaluating [b]market frequency[/b] in a practical, visual way:

• Identify how often structure shifts occur within fixed interaction intervals
• Compare expansion and compression behavior across equal bar cycles
• Study how trends evolve relative to consistent “market beats”
• Align other tools (such as oscillators or wave models) to cycle boundaries
• Evaluate whether price is accelerating or decelerating across repeating segments

By observing how price behaves between each cycle line, traders can begin to recognize repeating structural rhythm — or the absence of it.

[b]Key Concept: Frequency Visualization[/b]

While the indicator is extremely simple, it becomes powerful when viewed through the lens of frequency:

• Tight clustering of movement between lines = high-frequency / choppy environment
• Strong directional movement across multiple cycles = low-frequency trending behavior
• Irregular behavior between cycles = unstable or transitional regimes

This makes it a lightweight but effective way to visually assess how “fast” or “slow” the market is behaving in structural terms.

[b]Why It’s Useful[/b]

The strength of this indicator lies in its simplicity:

• No complex calculations
• No lagging signals
• No assumptions about price direction

Just clean, repeatable segmentation of market activity.

Despite its simplicity, it becomes a powerful analytical foundation when combined with other tools such as cycle waves, efficiency models, or structure-based systems.

[b]Summary[/b]

This indicator turns price into a series of equal behavioral intervals, allowing traders to study frequency, rhythm, and structural consistency in a clean and intuitive way. It is intentionally minimal — designed not to predict, but to reveal how the market behaves over repeated cycles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Forex_Steward

//@version=6
indicator("Time Intervals (Bars)", overlay=true)

//====================================================
// INPUTS
//====================================================

barsPerCycle = input.int(25, "Bars Per Cycle", minval=1)

lineColor = input.color(color.gray, "Line Color")
lineWidth = input.int(1, "Line Width", minval=1, maxval=4)
lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

comColor = input.color(color.blue, "Center Dot Color")

//====================================================
// STYLE
//====================================================

style = switch lineStyle
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

//====================================================
// STATE
//====================================================

var float cycleHigh = na
var float cycleLow = na
var int cycleStartIndex = na

// Sum of every candle's height in the current interval
var float heightSum = 0.0

// Previous completed dot price
var float previousDotPrice = na

// Current dot direction
var bool dotUp = false
var bool dotDown = false

//====================================================
// INITIALIZE
//====================================================

if na(cycleStartIndex)
    cycleStartIndex := bar_index
    cycleHigh := high
    cycleLow := low
    heightSum := high - low

//====================================================
// CYCLE DETECTION
//====================================================

newCycle = bar_index > 0 and bar_index % barsPerCycle == 0

if newCycle

    //================================================
    // PREVIOUS CYCLE END
    //================================================

    cycleEndIndex = bar_index - 1

    //================================================
    // VERTICAL CYCLE LINE
    //================================================

    line.new(
         x1=bar_index,
         y1=high,
         x2=bar_index,
         y2=low,
         extend=extend.both,
         color=lineColor,
         width=lineWidth,
         style=style
     )

    //================================================
    // HEIGHT-SUM CENTER
    //================================================

    // 50% of the total candle-height sum
    halfHeightSum = heightSum / 2.0

    // Accumulate candle heights from oldest → newest
    float cumulativeHeight = 0.0
    int centerIndex = cycleStartIndex

    for i = barsPerCycle to 1
        candleHeight = high[i] - low[i]
        cumulativeHeight += candleHeight

        if cumulativeHeight >= halfHeightSum
            centerIndex := bar_index - i
            break

    //================================================
    // CENTER DOT PRICE
    //================================================

    centerOffset = bar_index - centerIndex

    centerPrice = (high[centerOffset] + low[centerOffset]) / 2.0

    //================================================
    // DOT DIRECTION
    //================================================

    dotUp := not na(previousDotPrice) and centerPrice > previousDotPrice
    dotDown := not na(previousDotPrice) and centerPrice < previousDotPrice

    // Store current dot for next comparison
    previousDotPrice := centerPrice

    //================================================
    // CENTER CIRCLE
    //================================================

    label.new(
        x=centerIndex,
        y=centerPrice,
        text="",
        style=label.style_circle,
        color=comColor,
        size=size.tiny
    )

    //================================================
    // DEBUG TRIANGLES
    //================================================

    if dotUp
        label.new(
            x=centerIndex,
            y=centerPrice,
            text="",
            style=label.style_triangleup,
            color=color.green,
            size=size.tiny
        )

    if dotDown
        label.new(
            x=centerIndex,
            y=centerPrice,
            text="",
            style=label.style_triangledown,
            color=color.red,
            size=size.tiny
        )

    //================================================
    // RESET FOR NEW CYCLE
    //================================================

    cycleStartIndex := bar_index
    cycleHigh := high
    cycleLow := low
    heightSum := high - low

//====================================================
// UPDATE CURRENT CYCLE
//====================================================

// Don't double-count the boundary bar.
// It was already initialized above when a new cycle began.

if not newCycle
    cycleHigh := math.max(cycleHigh, high)
    cycleLow := math.min(cycleLow, low)

    // Add current candle's height
    heightSum += high - low
````

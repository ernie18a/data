# Moving Average Liquidity Sweeps - Candle Iron Core

- url: https://www.tradingview.com/script/r5Q1yDz4-Moving-Average-Liquidity-Sweeps-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;4a0fae8393894053beb71c7707815dd2
- version: 1.0

## Description

[b]Moving Average Liquidity Sweeps - Candle Iron Core[/b]

[b]OVERVIEW[/b]

Moving Average Liquidity Sweeps is a rule-based indicator designed to identify wick-based sweeps around a dynamically calculated moving average.

Unlike a fixed horizontal liquidity level, a moving average continuously changes with price. This indicator uses the selected EMA or SMA as a dynamic reference and evaluates how individual candles interact with it.

A candle is not classified as a sweep simply because its wick touches or crosses the moving average.

To qualify, the interaction must satisfy independent conditions involving:

[list]
[*]The position of the candle body relative to the moving average.
[*]The total length of the wick.
[*]The actual depth of penetration beyond the moving average.
[/list]

The purpose is to provide a configurable and repeatable method for distinguishing qualifying wick-based interactions from ordinary touches or shallow retests of a moving average.


[b]CORE CONCEPT[/b]

The selected moving average acts as the dynamic reference level.

Users can choose:

[list]
[*][b]EMA - Exponential Moving Average[/b]
[*][b]SMA - Simple Moving Average[/b]
[*][b]Moving Average Length[/b]
[*][b]Moving Average Source[/b]
[/list]

For example, the indicator can evaluate interactions with a 21 EMA, 89 SMA, 200 EMA, or any other user-defined combination.

The moving average itself does not determine whether an interaction qualifies as a sweep.

The candle must independently satisfy the sweep conditions described below.


[b]MOVING AVERAGE CALCULATION[/b]

When EMA is selected, the script calculates an Exponential Moving Average using the selected source and length.

When SMA is selected, the script calculates a Simple Moving Average using the selected source and length.

The resulting value becomes the Liquidity Moving Average used as the reference for each candle.

Because the moving average is recalculated over time, the reference level evaluated by the script changes from bar to bar.


[b]TWO INDEPENDENT PERCENTAGE FILTERS[/b]

The indicator separates two measurements:

[list]
[*][b]Minimum Wick Length (%)[/b]
[*][b]Minimum Sweep Depth Beyond MA (%)[/b]
[/list]

These measurements serve different purposes.

A candle can have a large wick while only slightly crossing the moving average.

Conversely, crossing the moving average does not necessarily mean that the wick itself is significant.

Requiring both conditions provides additional control over what the user chooses to classify as a qualifying sweep.


[b]1. MINIMUM WICK LENGTH[/b]

This parameter evaluates the complete wick responsible for the interaction.

For a sweep below the moving average:

[quote]
Lower edge of candle body → Candle Low
[/quote]

For a sweep above the moving average:

[quote]
Upper edge of candle body → Candle High
[/quote]

The lower edge of the candle body is defined as the lower value between Open and Close.

The upper edge of the candle body is defined as the higher value between Open and Close.

Therefore, the calculation works consistently for both bullish and bearish candles.

The percentage calculation used by the indicator is:

[quote]
Lower Wick % = (Body Low - Low) / Body Low × 100

Upper Wick % = (High - Body High) / Body High × 100
[/quote]

The complete wick must meet or exceed the Minimum Wick Length selected by the user.


[b]2. MINIMUM SWEEP DEPTH BEYOND MA[/b]

Sweep Depth measures a different distance.

Instead of measuring the complete wick, it measures only how far price extends beyond the moving average.

For a sweep below:

[quote]
Moving Average → Candle Low
[/quote]

For a sweep above:

[quote]
Moving Average → Candle High
[/quote]

The percentage calculation is:

[quote]
Sweep Depth Below % = (Moving Average - Low) / Moving Average × 100

Sweep Depth Above % = (High - Moving Average) / Moving Average × 100
[/quote]

This condition helps distinguish a qualifying penetration from a candle that merely touches or moves slightly beyond the moving average.


[b]SWEEP ABOVE MOVING AVERAGE[/b]

A candle qualifies as a Sweep Above when all of the following conditions are satisfied:

[list=1]
[*]The entire candle body remains at or below the moving average.
[*]The upper wick crosses above the moving average.
[*]The complete upper wick meets or exceeds the selected Minimum Wick Length.
[*]The distance from the moving average to the candle High meets or exceeds the Minimum Sweep Depth Beyond MA.
[*]The selected direction settings allow sweeps above the moving average.
[/list]

When all conditions are satisfied, a downward triangle is plotted above the candle.


[b]SWEEP BELOW MOVING AVERAGE[/b]

A candle qualifies as a Sweep Below when all of the following conditions are satisfied:

[list=1]
[*]The entire candle body remains at or above the moving average.
[*]The lower wick crosses below the moving average.
[*]The complete lower wick meets or exceeds the selected Minimum Wick Length.
[*]The distance from the moving average to the candle Low meets or exceeds the Minimum Sweep Depth Beyond MA.
[*]The selected direction settings allow sweeps below the moving average.
[/list]

When all conditions are satisfied, an upward triangle is plotted below the candle.


[b]WHY BODY POSITION MATTERS[/b]

The candle body is intentionally required to remain on the original side of the moving average.

A candle whose body crosses through the moving average represents a different type of interaction from a candle that penetrates the level only with its wick.

For this reason:

[quote]
Sweep Above → Body remains below the MA.

Sweep Below → Body remains above the MA.
[/quote]

This allows the indicator to focus specifically on wick-based interactions rather than classifying every candle that crosses a moving average as a sweep.


[b]WHY WICK LENGTH AND SWEEP DEPTH ARE SEPARATE[/b]

Consider a candle with a large lower wick.

The candle may satisfy the Minimum Wick Length requirement while extending only slightly below the moving average.

Without an additional depth requirement, a shallow interaction could qualify solely because the candle happened to have a long wick.

The Minimum Sweep Depth Beyond MA solves this by requiring price to travel a separately defined minimum distance beyond the moving average.

Therefore:

[quote]
Wick Length measures the wick itself.

Sweep Depth measures the penetration beyond the moving average.
[/quote]

A qualifying signal must satisfy both.


[b]SWEEP DIRECTION[/b]

The indicator allows users to select:

[list]
[*][b]Both[/b] - Detect interactions above and below the moving average.
[*][b]Above MA[/b] - Detect only sweeps above the moving average.
[*][b]Below MA[/b] - Detect only sweeps below the moving average.
[/list]


[b]CANDLE CLOSE CONFIRMATION[/b]

The [b]Confirm only after candle close[/b] option determines whether the script waits for the current candle to close before confirming a signal.

When enabled, a sweep is marked only after the bar is confirmed.

This is particularly relevant because the High, Low and Close of an active candle can continue changing before the candle closes.


[b]VISUAL SETTINGS[/b]

Users can customize:

[list]
[*]Whether the moving average is displayed.
[*]Moving Average color.
[*]Moving Average width.
[*]Sweep marker color.
[/list]

The plotted moving average corresponds directly to the dynamic reference used by the sweep calculations.


[b]HOW TO USE[/b]

A basic workflow is:

[list=1]
[*]Select EMA or SMA.
[*]Choose the Moving Average Length.
[*]Select the Moving Average Source.
[*]Define the Minimum Wick Length.
[*]Define the Minimum Sweep Depth Beyond MA.
[*]Choose whether to detect sweeps above, below, or in both directions.
[*]Optionally require candle-close confirmation.
[*]Evaluate qualifying interactions within the context of the user's own trading methodology.
[/list]


[b]EXAMPLE[/b]

Suppose a trader selects a 200 EMA.

A candle trades below the EMA and its upper wick extends through it.

Crossing the EMA alone does not produce a signal.

For the candle to qualify as a Sweep Above:

[list]
[*]Its complete body must remain at or below the EMA.
[*]Its upper wick must cross the EMA.
[*]Its complete upper wick must satisfy the Minimum Wick Length.
[*]The portion extending beyond the EMA must satisfy the Minimum Sweep Depth Beyond MA.
[/list]

Only when all conditions are satisfied does the indicator plot the sweep marker.


[b]ORIGINALITY AND PURPOSE[/b]

This indicator is not intended to introduce another moving-average crossover system.

The moving average serves only as a dynamically changing reference level.

The script's primary functionality is the classification of candle interactions around that reference using three independent structural conditions:

[list]
[*]Candle-body position relative to the moving average.
[*]Minimum total wick length.
[*]Minimum penetration depth beyond the moving average.
[/list]

Separating total wick length from actual penetration depth is particularly important because the two measurements describe different characteristics of the candle.

This combination allows users to define a consistent threshold for wick-based interactions with dynamic EMA or SMA levels rather than treating every touch, crossover, or wick penetration as equivalent.


[b]ALERTS[/b]

Alert conditions are included for:

[list]
[*]Liquidity Sweep Above MA
[*]Liquidity Sweep Below MA
[/list]

The alerts use the same conditions as the corresponding visual markers.


[b]IMPORTANT NOTES AND LIMITATIONS[/b]

The term "Liquidity Sweep" in this indicator describes a candle interaction that satisfies the quantitative rules defined above.

The indicator does not observe the exchange order book and therefore does not confirm the presence of resting orders, stop-loss concentrations, institutional orders, or actual available liquidity at the moving average.

Likewise, an EMA or SMA is not inherently a liquidity level.

The moving average is used by this script as a dynamic reference selected by the user for evaluating wick behavior.

A qualifying sweep does not predict that price will reverse, continue, or produce a profitable trading opportunity.

Moving averages, volatility and candle characteristics can behave differently across assets and timeframes. Parameters should therefore be evaluated specifically for the market, timeframe and methodology in which they are intended to be used.

This indicator does not provide Buy or Sell signals and does not guarantee future market behavior.

## Source Code

````pine
//@version=6
// © Indicator created by Candle Iron Core
// Purpose: objectively identify Liquidity Sweeps around a moving average
// using a minimum wick percentage and wick-only confirmation.

indicator(
     "Moving Average Liquidity Sweeps - Candle Iron Core",
     overlay = true,
     precision = 2
)

// =====================================================
// INPUTS
// =====================================================

// ---------- Moving Average ----------
maType = input.string(
     "EMA",
     "Moving Average Type",
     options = ["EMA", "SMA"]
)

maLength = input.int(
     21,
     "Moving Average Length",
     minval = 1
)

maSource = input.source(
     close,
     "Moving Average Source"
)

// ---------- Sweep Rule ----------
penetrationPct = input.float(
     1.0,
     "Minimum Wick Length (%)",
     minval = 0.0,
     step = 0.1
)

sweepDirection = input.string(
     "Both",
     "Sweep Direction",
     options = ["Both", "Above MA", "Below MA"]
)

confirmedBarsOnly = input.bool(
     true,
     "Confirm only after candle close"
)

// ---------- Visuals ----------
showMA = input.bool(
     true,
     "Show Moving Average"
)

maColor = input.color(
     color.purple,
     "Moving Average Color"
)

maWidth = input.int(
     2,
     "Moving Average Width",
     minval = 1,
     maxval = 5
)

arrowColor = input.color(
     color.rgb(230, 130, 0),
     "Sweep Arrow Color"
)


// =====================================================
// MOVING AVERAGE
// =====================================================

liquidityLevel = maType == "EMA" ?
     ta.ema(maSource, maLength) :
     ta.sma(maSource, maLength)


// =====================================================
// PLOT MOVING AVERAGE
// =====================================================

plot(
     showMA ? liquidityLevel : na,
     title = "Liquidity Moving Average",
     color = maColor,
     linewidth = maWidth
)


// =====================================================
// LIQUIDITY SWEEP CONDITIONS
// =====================================================

// Real candle body boundaries.
// Works identically for bullish and bearish candles.

bodyLow  = math.min(open, close)
bodyHigh = math.max(open, close)


// -----------------------------------------------------
// WICK LENGTH PERCENTAGE
// -----------------------------------------------------

// LOWER WICK:
//
// Percentage distance from the lower edge of the
// candle body to the candle Low.

penetrationBelowPct =
     ((bodyLow - low) / bodyLow) * 100.0


// UPPER WICK:
//
// Percentage distance from the upper edge of the
// candle body to the candle High.

penetrationAbovePct =
     ((high - bodyHigh) / bodyHigh) * 100.0


// =====================================================
// DIRECTION FILTER
// =====================================================

allowAbove =
     sweepDirection == "Both" or
     sweepDirection == "Above MA"

allowBelow =
     sweepDirection == "Both" or
     sweepDirection == "Below MA"


// =====================================================
// BAR CONFIRMATION
// =====================================================

barConfirmed =
     confirmedBarsOnly ?
     barstate.isconfirmed :
     true


// =====================================================
// SWEEP ABOVE MOVING AVERAGE
// =====================================================
//
// Requirements:
//
// 1. Entire candle body remains BELOW the MA.
// 2. Upper wick crosses ABOVE the MA.
// 3. Complete upper wick reaches the minimum
//    percentage defined by the user.
//
// =====================================================

// =====================================================
// SWEEP ABOVE MOVING AVERAGE
// =====================================================

sweepDepthBelowPct =
     ((liquidityLevel - low) / liquidityLevel) * 100.0

sweepDepthAbovePct =
     ((high - liquidityLevel) / liquidityLevel) * 100.0

minimumSweepDepthPct = input.float(
     0.5,
     "Minimum Sweep Depth Beyond MA (%)",
     minval = 0.0,
     step = 0.05
)
        
sweepAbove =
     barConfirmed and
     allowAbove and
     not na(liquidityLevel) and

     // Entire body must remain below the MA
     bodyHigh <= liquidityLevel and

     // Wick must cross the MA
     high > liquidityLevel and

     // Complete wick must have sufficient length
     penetrationAbovePct >= penetrationPct and

     // Wick must penetrate sufficiently beyond the MA
     sweepDepthAbovePct >= minimumSweepDepthPct


// =====================================================
// SWEEP BELOW MOVING AVERAGE
// =====================================================

sweepBelow =
     barConfirmed and
     allowBelow and
     not na(liquidityLevel) and

     // Entire body must remain above the MA
     bodyLow >= liquidityLevel and

     // Wick must cross the MA
     low < liquidityLevel and

     // Complete wick must have sufficient length
     penetrationBelowPct >= penetrationPct and

     // Wick must penetrate sufficiently beyond the MA
     sweepDepthBelowPct >= minimumSweepDepthPct


// =====================================================
// SWEEP ARROWS
// =====================================================

plotshape(
     sweepAbove,
     title = "Liquidity Sweep Above MA",
     style = shape.triangledown,
     location = location.abovebar,
     color = arrowColor,
     size = size.small
)

plotshape(
     sweepBelow,
     title = "Liquidity Sweep Below MA",
     style = shape.triangleup,
     location = location.belowbar,
     color = arrowColor,
     size = size.small
)


// =====================================================
// ALERTS
// =====================================================

alertcondition(
     sweepAbove,
     title = "Liquidity Sweep Above MA",
     message = "Liquidity Sweep ABOVE the selected moving average."
)

alertcondition(
     sweepBelow,
     title = "Liquidity Sweep Below MA",
     message = "Liquidity Sweep BELOW the selected moving average."
)
````

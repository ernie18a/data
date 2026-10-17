# Liquidity Sweep with Deviation - Candle Iron Core

- url: https://www.tradingview.com/script/PB3OdV7M-Liquidity-Sweep-with-Deviation-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;7c3f62ec58ba44569576ac9e44d425b4
- version: 1.0

## Description

[b]Liquidity Sweep with Deviation - Candle Iron Core[/b]

[b]OVERVIEW[/b]

Liquidity Sweep with Deviation is a rule-based tool designed to identify wick-based sweeps around a user-defined liquidity level.

Instead of classifying every touch or small penetration of a level as a liquidity sweep, the indicator applies objective conditions to distinguish a qualifying sweep from a simple retest or minor interaction with the level.

The user first defines a specific price as the Liquidity Level. This can represent any price level relevant to the user's analysis, such as a swing high, swing low, previous high/low, daily open, weekly open, monthly open, yearly open, support, resistance, or another manually selected reference.

The indicator then evaluates how each candle interacts with that level.


[b]CORE CONCEPT[/b]

A liquidity sweep, for the purposes of this indicator, requires the wick to cross a defined liquidity level while the candle body remains on the original side of that level.

However, crossing the level alone is not enough.

The indicator uses two independent percentage filters:

[list]
[*][b]Minimum Wick Length (%)[/b]
[*][b]Minimum Sweep Depth (%)[/b]
[/list]

This distinction is the main purpose of the script.

It allows users to separately control:

[list]
[*]How significant the wick itself must be.
[*]How far price must actually travel beyond the liquidity level.
[/list]


[b]1. MINIMUM WICK LENGTH[/b]

This parameter measures the complete wick responsible for the sweep.

For a sweep below the level:

[quote]
Lower edge of candle body → Candle Low
[/quote]

For a sweep above the level:

[quote]
Upper edge of candle body → Candle High
[/quote]

The percentage is calculated relative to the corresponding edge of the candle body.

This filter prevents candles with very small wicks from qualifying simply because they crossed the selected level.


[b]2. MINIMUM SWEEP DEPTH[/b]

Sweep Depth measures only the portion of price movement that extends beyond the defined Liquidity Level.

For a sweep below:

[quote]
Liquidity Level → Candle Low
[/quote]

For a sweep above:

[quote]
Liquidity Level → Candle High
[/quote]

This is intentionally different from Wick Length.

A candle may have a large wick but penetrate the liquidity level by only a very small amount. Without a separate depth requirement, that interaction could be classified as a sweep even when it behaves more like a precise retest of the level.

Minimum Sweep Depth allows the user to determine how far price must move beyond the level before the interaction qualifies.


[b]VALID SWEEP CONDITIONS[/b]

[b]Sweep Below[/b]

A candle qualifies as a Sweep Below when all of the following conditions are satisfied:

[list=1]
[*]The entire candle body remains at or above the Liquidity Level.
[*]The lower wick crosses below the Liquidity Level.
[*]The complete lower wick meets or exceeds the Minimum Wick Length.
[*]Price penetrates below the Liquidity Level by at least the Minimum Sweep Depth.
[/list]

When all conditions are satisfied, an upward triangle is plotted below the candle.


[b]Sweep Above[/b]

A candle qualifies as a Sweep Above when all of the following conditions are satisfied:

[list=1]
[*]The entire candle body remains at or below the Liquidity Level.
[*]The upper wick crosses above the Liquidity Level.
[*]The complete upper wick meets or exceeds the Minimum Wick Length.
[*]Price penetrates above the Liquidity Level by at least the Minimum Sweep Depth.
[/list]

When all conditions are satisfied, a downward triangle is plotted above the candle.


[b]WHY TWO PERCENTAGE FILTERS?[/b]

Wick Length and Sweep Depth measure two different characteristics.

Consider a candle with a large lower wick that barely crosses a support level.

Its wick may satisfy the Minimum Wick Length requirement, but its penetration beyond the level may be extremely small.

With this indicator, the candle must satisfy both requirements.

This provides a configurable framework for separating:

[quote]
A wick that merely interacts with a level

from

A wick that penetrates the level by a user-defined minimum amount.
[/quote]


[b]LIQUIDITY ZONE[/b]

The indicator displays a visual zone around the selected Liquidity Level.

The upper and lower boundaries correspond to the Minimum Sweep Depth selected by the user.

Therefore, the zone is not only a visual reference.

For a qualifying Sweep Above, the wick must reach or exceed the upper depth threshold.

For a qualifying Sweep Below, the wick must reach or exceed the lower depth threshold.

The zone color and transparency can be customized.


[b]LIQUIDITY LEVEL MODES[/b]

The indicator provides two methods for defining the reference level:

[list]
[*][b]Manual Price[/b] — The user enters the exact price level to evaluate.
[*][b]Current Asset Price[/b] — The indicator establishes the reference from the current/recent chart price according to the script's automatic-level logic.
[/list]

Manual Price is particularly useful when evaluating predefined structural or liquidity references.


[b]SWEEP DIRECTION[/b]

Users can choose which interactions should be detected:

[list]
[*]Both
[*]Above Level
[*]Below Level
[/list]

This allows the indicator to be adapted to the directional context being studied.


[b]CANDLE CLOSE CONFIRMATION[/b]

The option [b]Confirm only after candle close[/b] can be enabled to require the candle to be confirmed before a sweep signal is displayed.

When enabled, the final Open, High, Low and Close of the completed candle determine whether the conditions were satisfied.


[b]VISUAL CUSTOMIZATION[/b]

Users can customize:

[list]
[*]Liquidity Level color
[*]Liquidity Zone color
[*]Liquidity Zone transparency
[*]Sweep arrow color
[*]Visibility of the Liquidity Zone
[*]Visibility of price labels
[*]Price label text color
[*]Price label horizontal offset
[/list]


[b]HOW TO USE[/b]

A basic workflow is:

[list=1]
[*]Identify a price level that is relevant to your analysis.
[*]Enter that price as the Manual Liquidity Level.
[*]Define the Minimum Wick Length required for a candle to qualify.
[*]Define the Minimum Sweep Depth required beyond the level.
[*]Select whether sweeps should be detected above, below, or in both directions.
[*]Evaluate qualifying signals within the context of your own trading methodology.
[/list]


[b]EXAMPLE[/b]

Suppose a trader defines 93,000 as a liquidity level.

For a Sweep Below, simply trading below 93,000 is not sufficient.

The candle body must remain at or above 93,000, while its lower wick crosses below it.

The complete lower wick must satisfy the selected Minimum Wick Length, and the portion extending below 93,000 must independently satisfy the selected Minimum Sweep Depth.

Only when all conditions are satisfied will the indicator mark the candle as a qualifying Sweep Below.


[b]ORIGINALITY AND PURPOSE[/b]

The purpose of this script is not to automatically determine where liquidity exists or to label every wick through a price level as a liquidity sweep.

Its purpose is to provide an objective and configurable framework for testing user-defined liquidity levels.

The script separates two measurements that are often treated as a single condition:

[list]
[*]The total length of the wick performing the interaction.
[*]The actual depth of penetration beyond the liquidity level.
[/list]

Combined with the requirement that the candle body remains on the original side of the level, these independent conditions allow users to define and consistently reproduce their own threshold for what constitutes a qualifying liquidity sweep.


[b]ALERTS[/b]

Alert conditions are included for:

[list]
[*]Liquidity Sweep Above
[*]Liquidity Sweep Below
[/list]

These alerts follow the same conditions used by the visual sweep markers.


[b]IMPORTANT NOTES[/b]

This indicator does not automatically identify institutional liquidity, resting orders, stop-loss concentrations, or future price reactions.

A Liquidity Level is a price reference selected by the user. The script evaluates candle behavior around that reference according to the mathematical conditions described above.

A detected sweep is therefore a classification of price behavior according to the selected parameters, not a prediction that price will reverse or continue.

Different assets and timeframes have different volatility characteristics. Minimum Wick Length and Minimum Sweep Depth values should therefore be evaluated for the specific market, timeframe, and methodology in which they are used.

The indicator does not provide Buy or Sell signals and does not guarantee that a detected sweep will produce a favorable trading outcome.

## Source Code

````pine
//@version=6
// © Indicator created by Candle Iron Core
// Purpose: objectively identify Liquidity Sweeps around a defined price level
// using minimum wick length, minimum sweep depth, and wick-only confirmation.

indicator(
     "Liquidity Sweep with Deviation - Candle Iron Core",
     overlay = true,
     precision = 2
)

// =====================================================
// INPUTS
// =====================================================

// ---------- Liquidity Level ----------
levelMode = input.string(
     "Manual Price",
     "Liquidity Level Mode",
     options = ["Current Asset Price", "Manual Price"]
)

manualLevel = input.float(
     80000.0,
     "Manual Liquidity Level",
     step = 0.01
)

// ---------- Sweep Rules ----------

// Minimum length of the COMPLETE wick,
// measured from the candle body to the wick extreme.
wickLengthPct = input.float(
     2.0,
     "Minimum Wick Length (%)",
     minval = 0.0,
     step = 0.1
)

// Minimum penetration beyond the Liquidity Level,
// measured from the level to the wick extreme.
sweepDepthPct = input.float(
     0.25,
     "Minimum Sweep Depth (%)",
     minval = 0.0,
     step = 0.05
)

sweepDirection = input.string(
     "Both",
     "Sweep Direction",
     options = ["Both", "Above Level", "Below Level"]
)

confirmedBarsOnly = input.bool(
     true,
     "Confirm only after candle close"
)

// ---------- Visuals ----------
showZone = input.bool(
     true,
     "Show Liquidity Zone"
)

levelColor = input.color(
     color.black,
     "Liquidity Level Color"
)

zoneColor = input.color(
     color.purple,
     "Liquidity Zone Color"
)

zoneTransparency = input.int(
     85,
     "Liquidity Zone Transparency",
     minval = 0,
     maxval = 100
)

arrowColor = input.color(
     color.rgb(230, 130, 0),
     "Sweep Arrow Color"
)

showPriceLabels = input.bool(
     true,
     "Show Level Prices"
)

priceTextColor = input.color(
     color.white,
     "Price Text Color"
)

rightOffset = input.int(
     10,
     "Price Label Right Offset",
     minval = 0,
     maxval = 50
)

// =====================================================
// HELPERS
// =====================================================

fmt2(x) =>
    str.format("{0,number,0.00}", x)

// =====================================================
// AUTOMATIC / MANUAL LIQUIDITY LEVEL
// =====================================================

var float automaticLevel = na

if barstate.islastconfirmedhistory
    automaticLevel := close

liquidityLevel =
     levelMode == "Current Asset Price"
     ? automaticLevel
     : manualLevel

// =====================================================
// SWEEP DEPTH LEVELS
// =====================================================
//
// The visual zone now represents the minimum penetration
// required beyond the Liquidity Level.
//

sweepDepth =
     liquidityLevel * sweepDepthPct / 100.0

upperThreshold =
     liquidityLevel + sweepDepth

lowerThreshold =
     liquidityLevel - sweepDepth

// =====================================================
// DIRECTION FILTER
// =====================================================

allowAbove =
     sweepDirection == "Both" or
     sweepDirection == "Above Level"

allowBelow =
     sweepDirection == "Both" or
     sweepDirection == "Below Level"

// =====================================================
// BAR CONFIRMATION
// =====================================================

barConfirmed =
     confirmedBarsOnly
     ? barstate.isconfirmed
     : true

// =====================================================
// CANDLE BODY
// =====================================================
//
// Real body boundaries.
// Works identically for bullish and bearish candles.
//

bodyLow = math.min(open, close)
bodyHigh = math.max(open, close)

// =====================================================
// COMPLETE WICK LENGTH
// =====================================================
//
// IMPORTANT:
//
// This measures the COMPLETE wick.
// It does NOT measure penetration from the Liquidity Level.
//
// BELOW:
// lower edge of body -> Low
//
// ABOVE:
// upper edge of body -> High
//

wickLengthBelowPct =
     ((bodyLow - low) / bodyLow) * 100.0

wickLengthAbovePct =
     ((high - bodyHigh) / bodyHigh) * 100.0

// =====================================================
// SWEEP DEPTH
// =====================================================
//
// This is a SECOND and independent measurement.
//
// It measures how far the wick actually travels
// BEYOND the Liquidity Level.
//
// BELOW:
// Liquidity Level -> Low
//
// ABOVE:
// Liquidity Level -> High
//

sweepDepthBelowPct =
     ((liquidityLevel - low) / liquidityLevel) * 100.0

sweepDepthAbovePct =
     ((high - liquidityLevel) / liquidityLevel) * 100.0

// =====================================================
// LIQUIDITY SWEEP CONDITIONS
// =====================================================

// -----------------------------------------------------
// SWEEP ABOVE
// -----------------------------------------------------
//
// A valid Sweep Above requires:
//
// 1. Entire candle body remains at or below
//    the Liquidity Level.
//
// 2. Upper wick crosses above the Liquidity Level.
//
// 3. Complete upper wick reaches the minimum
//    Wick Length %.
//
// 4. Wick penetrates beyond the Liquidity Level
//    by at least the Minimum Sweep Depth %.
//
// -----------------------------------------------------

sweepAbove =
     barConfirmed and
     allowAbove and
     not na(liquidityLevel) and
     bodyHigh <= liquidityLevel and
     high > liquidityLevel and
     wickLengthAbovePct >= wickLengthPct and
     sweepDepthAbovePct >= sweepDepthPct

// -----------------------------------------------------
// SWEEP BELOW
// -----------------------------------------------------
//
// A valid Sweep Below requires:
//
// 1. Entire candle body remains at or above
//    the Liquidity Level.
//
// 2. Lower wick crosses below the Liquidity Level.
//
// 3. Complete lower wick reaches the minimum
//    Wick Length %.
//
// 4. Wick penetrates beyond the Liquidity Level
//    by at least the Minimum Sweep Depth %.
//
// -----------------------------------------------------

sweepBelow =
     barConfirmed and
     allowBelow and
     not na(liquidityLevel) and
     bodyLow >= liquidityLevel and
     low < liquidityLevel and
     wickLengthBelowPct >= wickLengthPct and
     sweepDepthBelowPct >= sweepDepthPct

// =====================================================
// SWEEP ARROWS
// =====================================================

plotshape(
     sweepAbove,
     title = "Liquidity Sweep Above",
     style = shape.triangledown,
     location = location.abovebar,
     color = arrowColor,
     size = size.small
)

plotshape(
     sweepBelow,
     title = "Liquidity Sweep Below",
     style = shape.triangleup,
     location = location.belowbar,
     color = arrowColor,
     size = size.small
)

// =====================================================
// LIQUIDITY ZONE DRAWING
// =====================================================

var line upperLine = na
var line baseLine = na
var line lowerLine = na
var linefill zoneFill = na

var label upperLabel = na
var label baseLabel = na
var label lowerLabel = na

if barstate.islast and not na(liquidityLevel)

    x1 = bar_index - 500
    x2 = bar_index + rightOffset

    if na(upperLine)

        upperLine := line.new(
             x1,
             upperThreshold,
             x2,
             upperThreshold,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = zoneColor,
             width = 1
        )

        baseLine := line.new(
             x1,
             liquidityLevel,
             x2,
             liquidityLevel,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = levelColor,
             width = 2
        )

        lowerLine := line.new(
             x1,
             lowerThreshold,
             x2,
             lowerThreshold,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = zoneColor,
             width = 1
        )

        zoneFill := linefill.new(
             upperLine,
             lowerLine,
             showZone
             ? color.new(zoneColor, zoneTransparency)
             : color.new(zoneColor, 100)
        )

    else

        line.set_xy1(
             upperLine,
             x1,
             upperThreshold
        )

        line.set_xy2(
             upperLine,
             x2,
             upperThreshold
        )

        line.set_xy1(
             baseLine,
             x1,
             liquidityLevel
        )

        line.set_xy2(
             baseLine,
             x2,
             liquidityLevel
        )

        line.set_xy1(
             lowerLine,
             x1,
             lowerThreshold
        )

        line.set_xy2(
             lowerLine,
             x2,
             lowerThreshold
        )

        line.set_color(
             upperLine,
             showZone
             ? zoneColor
             : color.new(zoneColor, 100)
        )

        line.set_color(
             lowerLine,
             showZone
             ? zoneColor
             : color.new(zoneColor, 100)
        )

        line.set_color(
             baseLine,
             levelColor
        )

        linefill.set_color(
             zoneFill,
             showZone
             ? color.new(zoneColor, zoneTransparency)
             : color.new(zoneColor, 100)
        )

    // =================================================
    // PRICE LABELS
    // =================================================

    if showPriceLabels

        labelX = bar_index + rightOffset

        if na(upperLabel)

            upperLabel := label.new(
                 labelX,
                 upperThreshold,
                 "",
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = priceTextColor
            )

            baseLabel := label.new(
                 labelX,
                 liquidityLevel,
                 "",
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = priceTextColor
            )

            lowerLabel := label.new(
                 labelX,
                 lowerThreshold,
                 "",
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = priceTextColor
            )

        label.set_xy(
             upperLabel,
             labelX,
             upperThreshold
        )

        label.set_text(
             upperLabel,
             fmt2(upperThreshold)
        )

        label.set_xy(
             baseLabel,
             labelX,
             liquidityLevel
        )

        label.set_text(
             baseLabel,
             fmt2(liquidityLevel)
        )

        label.set_xy(
             lowerLabel,
             labelX,
             lowerThreshold
        )

        label.set_text(
             lowerLabel,
             fmt2(lowerThreshold)
        )

        label.set_textcolor(
             upperLabel,
             priceTextColor
        )

        label.set_textcolor(
             baseLabel,
             priceTextColor
        )

        label.set_textcolor(
             lowerLabel,
             priceTextColor
        )

    else

        if not na(upperLabel)

            label.delete(upperLabel)
            label.delete(baseLabel)
            label.delete(lowerLabel)

            upperLabel := na
            baseLabel := na
            lowerLabel := na

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     sweepAbove,
     title = "Liquidity Sweep Above",
     message = "Liquidity Sweep ABOVE the defined liquidity level."
)

alertcondition(
     sweepBelow,
     title = "Liquidity Sweep Below",
     message = "Liquidity Sweep BELOW the defined liquidity level."
)
````

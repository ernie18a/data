# Support or Resistance with Deviation - Candle Iron Core

- url: https://www.tradingview.com/script/xC9Ag1s5-Support-or-Resistance-with-Deviation-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;cc4b404a094e4b268e0e6de074ff70f3
- version: 2.0

## Description

The [b]Support or Resistance with Deviation - Candle Iron Core[/b] indicator is designed to help traders visualize custom support and resistance zones by applying a percentage deviation around a user-defined reference price.

Unlike traditional support and resistance indicators, this tool does [b]not automatically detect support or resistance levels[/b]. Instead, it gives traders complete freedom to choose the most relevant price level according to their own market analysis and trading methodology.


By allowing traders to manually define a key price level and instantly project percentage-based deviation zones around it, the indicator provides a structured framework for risk management and price reaction analysis.

[b]Core Concept[/b]

The trader first selects a reference price that they consider important.

This reference may represent:

[list]
[*]A major support level.
[*]A major resistance level.
[*]A supply or demand zone.
[*]A daily, weekly, or monthly opening price.
[*]A liquidity pool.
[*]A swing high or swing low.
[*]Any price level identified through the trader's own analysis.
[/list]

Once the reference price is selected, the indicator calculates upper and lower deviation levels based on a user-defined percentage.

Mathematically:

[i]Deviation = Base Price × (Deviation % / 100)[/i]

[i]Upper Level = Base Price + Deviation[/i]

[i]Lower Level = Base Price − Deviation[/i]

The area between both levels creates a visual deviation zone that can be used as a framework for analyzing price behavior.

[b]Base Price Modes[/b]

[b]Current Asset Price[/b]

Automatically uses the latest market price of the current asset.

This mode was specifically designed to make the indicator immediately usable on any market without requiring manual adjustments. Traders can quickly apply the script to stocks, cryptocurrencies, futures, forex pairs, indices, or commodities and instantly obtain a deviation zone around the current market price.

[b]Manual Price[/b]

Allows traders to manually specify any custom price level.

This mode is particularly useful when analyzing previously identified support or resistance levels, institutional zones, swing highs/lows, or any important market reference.

[b]Indicator Components[/b]

[list]
[*][b]Upper Deviation Level:[/b] Base Price + Deviation.
[*][b]Base Price:[/b] Central reference selected by the trader.
[*][b]Lower Deviation Level:[/b] Base Price − Deviation.
[*][b]Deviation Zone:[/b] The shaded area between the upper and lower levels.
[/list]

[b]Practical Applications[/b]

This tool can be used to:

[list]
[*]Visualize custom support and resistance zones.
[*]Define objective stop-loss areas.
[*]Estimate take-profit targets.
[*]Identify potential liquidity areas.
[*]Analyze market expansion and contraction.
[*]Measure acceptable price deviation around key levels.
[*]Build zone-to-zone trading frameworks.
[*]Evaluate risk-to-reward scenarios.
[*]Assist mean reversion and range-based trading strategies.
[/list]

[b]Important Notes[/b]

[list]
[*]This indicator does not automatically detect support levels.
[*]This indicator does not automatically detect resistance levels.
[*]This indicator does not generate buy or sell signals.
[*]This indicator does not predict future market direction.
[/list]

The quality of the analysis depends entirely on the trader's ability to identify meaningful reference prices.

This script should be viewed as a visualization and risk management tool rather than a standalone trading system.

[b]Why This Indicator Is Different[/b]

Many support and resistance tools attempt to automatically identify market levels using predefined algorithms.

This indicator takes a different approach.

Instead of forcing a specific interpretation of market structure, it allows traders to apply their own discretion while providing a precise and objective framework for measuring price deviation around any selected level.

This makes the indicator flexible enough to adapt to virtually any trading style, market, or timeframe.

## Source Code

````pine
//@version=6
// © Indicator created by Candle Iron Core
// Purpose: visualize percentage deviation zones around the asset's current price or a manually defined base price.
indicator("Support and Resistance with Deviation - Candle Iron Core", overlay=true, precision=2)

// =====================
// Inputs
// =====================
basePriceMode = input.string("Current asset price", "Base price mode", options=["Current asset price", "Manual price"], tooltip="Selects the reference used to calculate the bands. 'Current asset price' uses the price of the latest candle and changes while that candle is forming. 'Manual price' uses the value entered in 'Manual base price'.")
manualBasePrice = input.float(70000.0, title="Manual base price", tooltip="Fixed price around which the bands are calculated. Only used when 'Manual price' is selected.")
percentage = input.float(1.0, title="Deviation (%)", step=0.1, tooltip="Percentage of the base price used to calculate the distance between the bands. With a positive value, the upper band is placed that percentage above the base price and the lower band below it. Increasing the positive percentage widens the zone; reducing it toward zero narrows it. A value of 0 makes all three levels coincide. A negative value reverses the bands.")
showPriceLabels = input.bool(true, title="Show prices on chart (upper/base/lower)", tooltip="Shows or hides the labels displaying the upper band, base level, and lower band prices. The lines and fill remain visible.")
textColor = input.color(color.black, "Price text color", tooltip="Selects the color of the price labels. This does not change the color of the lines or the fill.")
textSize = input.string("Normal", "Text size", options=["Tiny", "Small", "Normal"], tooltip="Adjusts the size of the price label text: tiny, small, or normal.")
rightOffset = input.int(10, "Right offset (bars)", minval=0, maxval=50, tooltip="Number of bar spaces separating the labels from the latest candle to the right. A larger value moves them farther away; 0 places them at the same horizontal position as the latest candle.")

// =====================
// Helper functions
// =====================
f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

fmt2(x) =>
    str.format("{0,number,0.00}", x)

// =====================
// Objects
// =====================
var line upperLine = na
var line baseLine = na
var line lowerLine = na
var linefill deviationFill = na
var label upperLabel = na
var label baseLabel = na
var label lowerLabel = na

// =====================
// Drawing on the latest bar
// =====================
if barstate.islast
    basePrice = basePriceMode == "Current asset price" ? close : manualBasePrice
    deviation = basePrice * percentage / 100.0
    upperBand = basePrice + deviation
    lowerBand = basePrice - deviation
    x1 = bar_index - 500
    x2 = bar_index + rightOffset

    if na(upperLine)
        upperLine := line.new(x1, upperBand, x2, upperBand, xloc=xloc.bar_index, extend=extend.both, color=color.teal, width=2)
        baseLine := line.new(x1, basePrice, x2, basePrice, xloc=xloc.bar_index, extend=extend.both, color=color.rgb(125, 126, 129), width=2)
        lowerLine := line.new(x1, lowerBand, x2, lowerBand, xloc=xloc.bar_index, extend=extend.both, color=color.teal, width=2)
        deviationFill := linefill.new(upperLine, lowerLine, color=color.new(#949697, 85))
    else
        line.set_xy1(upperLine, x1, upperBand)
        line.set_xy2(upperLine, x2, upperBand)
        line.set_xy1(baseLine, x1, basePrice)
        line.set_xy2(baseLine, x2, basePrice)
        line.set_xy1(lowerLine, x1, lowerBand)
        line.set_xy2(lowerLine, x2, lowerBand)

    if showPriceLabels
        labelX = bar_index + rightOffset
        if na(upperLabel)
            upperLabel := label.new(labelX, upperBand, "", xloc=xloc.bar_index, style=label.style_none, textcolor=textColor, color=color.new(color.white, 100), size=f_size(textSize))
            baseLabel := label.new(labelX, basePrice, "", xloc=xloc.bar_index, style=label.style_none, textcolor=textColor, color=color.new(color.white, 100), size=f_size(textSize))
            lowerLabel := label.new(labelX, lowerBand, "", xloc=xloc.bar_index, style=label.style_none, textcolor=textColor, color=color.new(color.white, 100), size=f_size(textSize))

        label.set_xy(upperLabel, labelX, upperBand)
        label.set_text(upperLabel, fmt2(upperBand))
        label.set_xy(baseLabel, labelX, basePrice)
        label.set_text(baseLabel, fmt2(basePrice))
        label.set_xy(lowerLabel, labelX, lowerBand)
        label.set_text(lowerLabel, fmt2(lowerBand))
        label.set_textcolor(upperLabel, textColor)
        label.set_textcolor(baseLabel, textColor)
        label.set_textcolor(lowerLabel, textColor)
        label.set_size(upperLabel, f_size(textSize))
        label.set_size(baseLabel, f_size(textSize))
        label.set_size(lowerLabel, f_size(textSize))
    else
        if not na(upperLabel)
            label.delete(upperLabel)
            label.delete(baseLabel)
            label.delete(lowerLabel)
            upperLabel := na
            baseLabel := na
            lowerLabel := na
````

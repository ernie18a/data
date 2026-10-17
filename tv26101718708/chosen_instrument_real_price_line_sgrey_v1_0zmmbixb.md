# Chosen Instrument Real Price Line - S.Grey v.1

- url: https://www.tradingview.com/script/0zMMBIxb/
- type: indicator
- pine_id: PUB;00ae0450960b46058c5d75fd7079da32
- version: 1.0

## Description

The Chosen Instrument Real Price Line indicator is designed to display the live price of any selected stock, index, futures contract, CFD, or custom TradingView symbol directly on your chart as a dynamic horizontal reference level. Unlike traditional comparison tools that only display percentage relationships or secondary panels, this indicator projects the real-time price level of the chosen instrument directly onto the active chart, allowing traders to visually compare markets in real time from a single chart window.

The indicator continuously tracks the selected instrument and plots its current live price as a customizable horizontal line. The line can be styled with different colors, thicknesses, and extension modes, giving the trader full visual control over how the reference level appears on the chart. The line can extend to the right, left, both directions, or remain as a fixed-width segment. A separate toggle also allows the line itself to be hidden completely while still keeping the label visible at the correct price level.

The label system is designed specifically for real-time intermarket comparison and spread monitoring. The label can display the selected instrument name, its current live price, the live price difference between the chosen instrument and the current chart instrument, or both values simultaneously. This makes the indicator especially useful for traders who monitor the relationship between CFDs and their underlying base instruments.

One of the most practical applications of this tool is tracking the difference between CFD products and their corresponding futures or index markets in real time. For example, a trader using a broker CFD such as SPX500USD can compare it directly against the underlying SPX index or ES futures contract. The indicator instantly shows whether the CFD is trading above or below the base instrument and by how many points. This allows traders to monitor broker spreads, temporary pricing inefficiencies, overnight premium or discount conditions, and market synchronization across different instruments without switching charts.

Because the difference is updated live, the indicator can also be used as a spread-monitoring tool during volatile market conditions. Traders can quickly identify moments when a CFD deviates unusually far from the underlying futures contract, which may help in execution timing, spread analysis, or broker comparison. This is particularly useful during high-impact news events, session transitions, overnight trading, or periods of reduced liquidity.

The indicator is also highly flexible for broader intermarket analysis. Traders can compare futures against cash indexes, ETFs against futures, sector ETFs against indexes, or even different brokers’ CFD feeds against each other. Since the selected instrument is fully customizable using TradingView symbols, virtually any supported market can be tracked as a live reference level.

The label itself is fully customizable and can be configured to display:

* only the real-time price,
* only the price difference versus the active chart,
* or both values together.

Importantly, the instrument name always remains visible regardless of the selected label mode, ensuring clear identification at all times.

This tool is particularly valuable for futures traders, CFD traders, index traders, arbitrage-oriented traders, and anyone monitoring the live relationship between correlated markets from a single chart environment.

## Source Code

````pine
//@version=5
indicator("Chosen Instrument Real Price Line - S.Grey v.1", overlay = true, max_lines_count = 10, max_labels_count = 10)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────

chosenSymbol = input.symbol("SPX", "Chosen Instrument")

showLine = input.bool(true, "Show Line")

lineColor = input.color(color.white, "Line Color")
lineStyleInput = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"])
lineWidth = input.int(2, "Line Thickness", minval = 1, maxval = 5)

lineLength = input.int(50, "Line Width / Length In Bars", minval = 1, maxval = 500)

lineExtensionInput = input.string(
     "Right",
     "Line Extension",
     options = ["None", "Right", "Left", "Both"])

// ─────────────────────────────────────────────
// Label Settings
// ─────────────────────────────────────────────

showLabel = input.bool(true, "Show Label")

labelMode = input.string(
     "Both",
     "Label Content",
     options = ["Price Only", "Difference Only", "Both"])

labelOffset = input.int(20, "Label Offset", minval = 1)

labelSizeInput = input.string(
     "Normal",
     "Label Size",
     options = ["Tiny", "Small", "Normal", "Large"])

labelTextColor = input.color(color.white, "Label Text Color")
labelBackgroundColor = input.color(color.black, "Label Background Color")

// ─────────────────────────────────────────────
// Functions
// ─────────────────────────────────────────────

f_lineStyle(_style) =>
    switch _style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

f_lineExtension(_ext) =>
    switch _ext
        "None"  => extend.none
        "Right" => extend.right
        "Left"  => extend.left
        "Both"  => extend.both

f_labelSize(_size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large

f_symbolName(_symbol) =>
    parts = str.split(_symbol, ":")

    array.size(parts) > 1 ?
         array.get(parts, 1) :
         _symbol

f_signedValue(_value) =>
    _value >= 0 ?
         "+" + str.tostring(_value, format.mintick) :
         str.tostring(_value, format.mintick)

// ─────────────────────────────────────────────
// Prices
// ─────────────────────────────────────────────

chosenPrice = request.security(chosenSymbol, timeframe.period, close)

chartPrice = close

priceDifference = chosenPrice - chartPrice

// ─────────────────────────────────────────────
// Label Text Logic
// ─────────────────────────────────────────────

symbolText = f_symbolName(chosenSymbol)

priceText = str.tostring(chosenPrice, format.mintick)

diffText = "Diff " + f_signedValue(priceDifference)

labelText = switch labelMode
    "Price Only"      => symbolText + " " + priceText
    "Difference Only" => symbolText + " " + diffText
    => symbolText + " " + priceText + " | " + diffText

// ─────────────────────────────────────────────
// Draw line and label
// ─────────────────────────────────────────────

var line priceLine = na
var label priceLabel = na

if barstate.islast and not na(chosenPrice)

    x1 = bar_index - lineLength
    x2 = bar_index

    // ───────── Line ─────────

    if showLine

        if na(priceLine)
            priceLine := line.new(
                 x1,
                 chosenPrice,
                 x2,
                 chosenPrice,
                 xloc = xloc.bar_index,
                 extend = f_lineExtension(lineExtensionInput),
                 color = lineColor,
                 style = f_lineStyle(lineStyleInput),
                 width = lineWidth)
        else
            line.set_xy1(priceLine, x1, chosenPrice)
            line.set_xy2(priceLine, x2, chosenPrice)

            line.set_extend(priceLine, f_lineExtension(lineExtensionInput))
            line.set_color(priceLine, lineColor)
            line.set_style(priceLine, f_lineStyle(lineStyleInput))
            line.set_width(priceLine, lineWidth)

    if not showLine and not na(priceLine)
        line.delete(priceLine)
        priceLine := na

    // ───────── Label ─────────

    if showLabel

        if na(priceLabel)
            priceLabel := label.new(
                 bar_index + labelOffset,
                 chosenPrice,
                 labelText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 color = labelBackgroundColor,
                 style = label.style_label_left,
                 textcolor = labelTextColor,
                 size = f_labelSize(labelSizeInput))
        else
            label.set_xy(priceLabel, bar_index + labelOffset, chosenPrice)

            label.set_text(priceLabel, labelText)

            label.set_textcolor(priceLabel, labelTextColor)

            label.set_color(priceLabel, labelBackgroundColor)

            label.set_size(priceLabel, f_labelSize(labelSizeInput))

    if not showLabel and not na(priceLabel)
        label.delete(priceLabel)
        priceLabel := na
````

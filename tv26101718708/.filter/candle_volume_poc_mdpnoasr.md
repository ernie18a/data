# Candle Volume POC

- url: https://www.tradingview.com/script/MdpNoAsR-Candle-Volume-POC/
- type: indicator
- pine_id: PUB;39a65ec37982428585f17e2934be70c4
- version: 5.0

## Description

Candle Volume POC estimates the point of control for each individual candle using lower-timeframe volume data.

The script builds price bins inside each candle, distributes lower-timeframe volume across the bins touched by each lower-timeframe candle, then marks the price area with the highest accumulated volume.

Default lower timeframe is 15 seconds for higher precision. If your TradingView plan does not support seconds data, use 1 minute instead.

Notes:
- This is an approximation because Pine Script does not provide true tick-level volume-at-price data.
- Lower timeframes improve precision but reduce how far back TradingView can calculate due to intrabar history limits.
- POC marks may extend to the right on bearish candles when the POC is hidden inside the candle body.

## Source Code

````pine
//@version=6
indicator("Candle Volume POC", overlay=true, max_labels_count=500, max_lines_count=500)

visibilityNote = input.bool(true, "NOTE: Bring indicator to front", group="IMPORTANT", tooltip="Open the indicator's More menu, then choose Visual order → Bring to front so POC markers display over candle bodies.")

rowMultiplier = input.string("4x", "Footprint row multiplier", options=["1x", "1.5x", "2x", "4x", "8x", "16x", "32x", "64x"], tooltip="Higher = lighter/faster, less precise. Lower = more precise, heavier.")

useManualTicks = input.bool(false, "Use manual ticks per row", tooltip="Turn on only if multiplier mode still does not show POC.")
manualTicksPerRow = input.int(100, "Manual ticks per row", minval=1, tooltip="Higher values are lighter/faster. Use this for extreme candle ranges.")

pocColor = input.color(#ADADAD, "POC marker color")
markerSizeInput = input.string("Tiny", "Marker size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
extendInsideBearBody = input.bool(false, "Extend right when inside bearish body")

f_baseTicksForTicker() =>
    root = syminfo.root
    mt = syminfo.mintick

    switch
        root == "ES" or root == "MES" => 2
        root == "NQ" or root == "MNQ" => 4
        root == "YM" or root == "MYM" => 1
        root == "RTY" or root == "M2K" => 2
        root == "CL" or root == "MCL" => 2
        root == "GC" or root == "MGC" => 2
        root == "SI" => 2
        syminfo.type == "forex" => mt <= 0.00001 ? 10 : 5
        syminfo.type == "crypto" => mt <= 0.000001 ? 1000 : mt <= 0.00001 ? 500 : mt <= 0.001 ? 250 : mt <= 0.01 ? 100 : 25
        syminfo.type == "stock" => mt <= 0.01 ? 5 : 1
        syminfo.type == "futures" => mt <= 0.01 ? 10 : 4
        => mt <= 0.000001 ? 1000 : mt <= 0.00001 ? 500 : mt <= 0.001 ? 100 : mt <= 0.01 ? 25 : 5

f_rowMultiplierValue() =>
    switch rowMultiplier
        "1x" => 1.0
        "1.5x" => 1.5
        "2x" => 2.0
        "4x" => 4.0
        "8x" => 8.0
        "16x" => 16.0
        "32x" => 32.0
        "64x" => 64.0

f_autoTicksPerRow() =>
    baseTicks = f_baseTicksForTicker()
    multiplier = f_rowMultiplierValue()

    int(math.max(1, math.ceil(baseTicks * multiplier)))

ticksPerRow = useManualTicks ? manualTicksPerRow : f_autoTicksPerRow()

markerSize = switch markerSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge" => size.huge
    => size.normal

var label warningLabel = na
var label[] pocLabels = array.new_label()
var line[] pocLines = array.new_line()

footprint fp = request.footprint(ticksPerRow)

float pocPrice = na

if not na(fp)
    volume_row pocRow = fp.poc()

    if not na(pocRow)
        pocPrice := math.avg(pocRow.up_price(), pocRow.down_price())

if not na(pocPrice)
    bodyLow = math.min(open, close)
    bodyHigh = math.max(open, close)
    pocInsideBody = pocPrice >= bodyLow and pocPrice <= bodyHigh
    bearishCandle = close < open
    useRightExtension = extendInsideBearBody and bearishCandle and pocInsideBody

    if useRightExtension
        newLine = line.new(
             x1=bar_index,
             y1=pocPrice,
             x2=bar_index + 1,
             y2=pocPrice,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=pocColor,
             width=1
         )

        array.push(pocLines, newLine)
    else
        newLabel = label.new(
             x=bar_index,
             y=pocPrice,
             text="━",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_center,
             color=color.new(pocColor, 100),
             textcolor=pocColor,
             size=markerSize
         )

        array.push(pocLabels, newLabel)

    while array.size(pocLabels) > 500
        label.delete(array.shift(pocLabels))

    while array.size(pocLines) > 500
        line.delete(array.shift(pocLines))

if barstate.islast
    label.delete(warningLabel)

    if na(fp)
        warningLabel := label.new(
             x=bar_index,
             y=high,
             text="No footprint data available. Increase row multiplier or use manual ticks per row.",
             style=label.style_label_down,
             textcolor=color.white,
             color=color.red,
             size=size.small
         )
````

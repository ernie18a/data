# GC 08-02 Zones

- url: https://www.tradingview.com/script/SrqIrCnf-GC-08-02-Zones/
- type: indicator
- pine_id: PUB;81bbd76b7a9d41c980788d4a32dd2b04
- version: 1.0

## Description

[b]GC 08-02 Zones — Gold Futures Round-Level Map[/b]

This indicator automatically maps out horizontal reaction zones around gold's round-number price levels — the "xx8 to xx2" bands that often act as short-term support/resistance on GC and MGC futures.

[b]How it works[/b]

The script rounds the current price to the nearest $10 level and plots a series of shaded zones above and below it, each spanning from the round number +2 to −2 (e.g. a zone around $3350 would run from 3352 down to 3348). These bands are drawn symmetrically around price and automatically re-center as price moves, so you always have a consistent map of nearby round-number levels without manually drawing lines.

[b]Features[/b]

[list]
[*]Adjustable number of zones displayed above/below price (1–50)
[*]Customizable zone fill color, border line color, style (solid/dashed/dotted), and width
[*]Optional price labels on each zone boundary
[*]Adjustable right-side offset and left-extension of lines
[*]Built-in warning label if applied to a symbol other than GC/MGC
[/list]

[b]Why round numbers matter[/b]

Round price levels tend to attract order flow — stops, limit orders, and psychological decision points cluster around them. Having these zones pre-mapped can help with spotting potential reaction areas, planning entries/exits, or simply keeping round-number context visible without cluttering the chart with manual drawings.

[b]Usage notes[/b]

This tool is designed specifically for gold futures (GC/MGC) given their $10 round-level structure. It is a visual reference only and does not generate buy/sell signals — always combine with your own strategy, market structure analysis, and risk management.

## Source Code

````pine
//@version=6
indicator("GC 08-02 Zones", shorttitle = "08-02", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)


// =================================
// INPUTS
// =================================
grp_zones   = "Zone Settings"
totalZones  = input.int(5, title="Total Zones on Screen", minval=1, maxval=50, group=grp_zones)
zoneRange   = 2


grp_style   = "Style Customization"
zoneBgColor = input.color(color.new(color.blue, 85), title="Zone Fill Color", group=grp_style)
lineColor   = input.color(color.new(color.blue, 50), title="Line Color", group=grp_style)
lineStyle   = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)
lineWidth   = input.int(2, title="Line Width", minval=1, maxval=5, group=grp_style)
extendLeft  = input.bool(true, title="Extend Lines Left", group=grp_style)
barOffset   = input.int(20, title="Right Offset (bars from cAAurrent)", minval=0, maxval=400, group=grp_style)

grp_label   = "Price Labels"
showPrice   = input.bool(true, title="Show Price on Lines", group=grp_label)
labelColor  = input.color(color.new(color.black, 0), title="Label Text Color", group=grp_label)
labelSize   = input.string("Normal", title="Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_label)


// Convert line style
var string lStyle = na
if lineStyle == "Solid"
    lStyle := line.style_solid
else if lineStyle == "Dashed"
    lStyle := line.style_dashed
else if lineStyle == "Dotted"
    lStyle := line.style_dotted

// Convert label size
var string lSize = na
if labelSize == "Tiny"
    lSize := size.tiny
else if labelSize == "Small"
    lSize := size.small
else if labelSize == "Normal"
    lSize := size.normal
else if labelSize == "Large"
    lSize := size.large


// =================================
// LOGIC & DRAWING
// =================================

bool isGold = str.startswith(syminfo.root, "GC") or str.startswith(syminfo.root, "MGC")

var table warningTable = table.new(position.top_right, 1, 1)
if barstate.isfirst
    if not isGold
        table.cell(warningTable, 0, 0, "⚠️ WARNING: Designed for GOLD Futures (GC/MGC) only", bgcolor=color.new(color.red, 20), text_color=color.white, text_size=size.normal)


var line[] topLines = array.new_line()
var line[] bottomLines = array.new_line()
var linefill[] fills = array.new_linefill()
var label[] topLabels = array.new_label()
var label[] bottomLabels = array.new_label()
var float[] labeledPrices = array.new_float()


if barstate.isfirst
    for i = 1 to totalZones
        tLine = line.new(x1=bar_index, y1=na, x2=bar_index + 1, y2=na, color=lineColor, width=lineWidth, style=lStyle)
        array.push(topLines, tLine)

        bLine = line.new(x1=bar_index, y1=na, x2=bar_index + 1, y2=na, color=lineColor, width=lineWidth, style=lStyle)
        array.push(bottomLines, bLine)

        f = linefill.new(tLine, bLine, zoneBgColor)
        array.push(fills, f)

        tl = label.new(x=bar_index, y=na, text="", style=label.style_label_left, textcolor=labelColor, size=lSize, color=color.new(color.white, 100))
        array.push(topLabels, tl)

        bl = label.new(x=bar_index, y=na, text="", style=label.style_label_left, textcolor=labelColor, size=lSize, color=color.new(color.white, 100))
        array.push(bottomLabels, bl)


if barstate.islast
    nearest10 = math.round(close / 10) * 10
    offset = math.floor(totalZones / 2)

    array.clear(labeledPrices)

    rightEdge = bar_index + barOffset
    lineExtend = extendLeft ? extend.left : extend.none

    for i = 0 to totalZones - 1
        step = i - offset

        centerLevel = nearest10 + (step * 10)
        topLevel    = centerLevel + zoneRange
        bottomLevel = centerLevel - zoneRange

        // Update top line
        tLine = array.get(topLines, i)
        line.set_xy1(tLine, bar_index, topLevel)
        line.set_xy2(tLine, rightEdge, topLevel)
        line.set_extend(tLine, lineExtend)

        // Update bottom line
        bLine = array.get(bottomLines, i)
        line.set_xy1(bLine, bar_index, bottomLevel)
        line.set_xy2(bLine, rightEdge, bottomLevel)
        line.set_extend(bLine, lineExtend)

        // Update fill
        f = array.get(fills, i)
        linefill.set_color(f, zoneBgColor)

        // Top label at end of line
        tl = array.get(topLabels, i)
        if showPrice and not array.includes(labeledPrices, topLevel)
            label.set_xy(tl, rightEdge, topLevel)
            label.set_text(tl, str.tostring(topLevel, "#"))
            label.set_textcolor(tl, labelColor)
            label.set_size(tl, lSize)
            label.set_style(tl, label.style_label_left)
            label.set_color(tl, color.new(color.white, 100))
            array.push(labeledPrices, topLevel)
        else
            label.set_text(tl, "")

        // Bottom label at end of line
        bl = array.get(bottomLabels, i)
        if showPrice and not array.includes(labeledPrices, bottomLevel)
            label.set_xy(bl, rightEdge, bottomLevel)
            label.set_text(bl, str.tostring(bottomLevel, "#"))
            label.set_textcolor(bl, labelColor)
            label.set_size(bl, lSize)
            label.set_style(bl, label.style_label_left)
            label.set_color(bl, color.new(color.white, 100))
            array.push(labeledPrices, bottomLevel)
        else
            label.set_text(bl, "")
````

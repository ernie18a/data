# NQ8020-GC0802

- url: https://www.tradingview.com/script/MMu8eyOJ-NQ8020-GC0802/
- type: indicator
- pine_id: PUB;5d9b0a23614d468089ff49899855421d
- version: 1.0

## Description

[b]Round-Level Zones — Auto NQ/GC Support & Resistance Map[/b]

This indicator automatically maps out horizontal reaction zones around round-number price levels for Nasdaq (NQ/MNQ) and Gold (GC/MGC) futures, adjusting its logic to match the instrument you're viewing.

[b]How it works[/b]

The script detects the symbol you're on and applies the appropriate round-level structure:

[list]
[*]NQ / MNQ → zones are drawn from xx80 to xx20 around each round hundred (e.g. a zone at the 24,000 level runs from 24,020 down to 23,980)
[*]GC / MGC → zones are drawn from xx8 to xx2 around each round ten (e.g. a zone at 3350 runs from 3352 down to 3348)
[/list]

Zones re-center automatically as price moves, giving you a consistent, always-current map of nearby round-number levels without manually drawing lines on each instrument.

[b]Features[/b]

[list]
[*]Works on both NQ/MNQ and GC/MGC — no separate indicators or settings to switch
[*]Adjustable number of zones displayed above/below price (1–50)
[*]Customizable zone fill color, border line color, style (solid/dashed/dotted), and width
[*]Optional price labels on each zone boundary
[*]Adjustable right-side offset and left-extension of lines
[*]On-chart warning if applied to an unsupported symbol
[/list]

[b]Why round numbers matter[/b]

Round price levels tend to attract order flow — stops, limit orders, and psychological decision points cluster around them. Having these zones pre-mapped can help with spotting potential reaction areas, planning entries/exits, or keeping round-number context visible without cluttering the chart with manual drawings.

[b]Usage notes[/b]

Designed specifically for the round-number structures of NQ/MNQ (hundreds) and GC/MGC (tens). This is a visual reference tool only and does not generate buy/sell signals — always combine with your own strategy, market structure analysis, and risk management.

## Source Code

````pine
//@version=6
indicator("NQ8020-GC0802", shorttitle = "8020-0802", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)


// =================================
// INPUTS
// =================================
grp_zones   = "Zone Settings"
totalZones  = input.int(5, title="Total Zones on Screen", minval=1, maxval=50, group=grp_zones)

grp_style   = "Style Customization"
zoneBgColor = input.color(color.new(color.blue, 85), title="Zone Fill Color", group=grp_style)
lineColor   = input.color(color.new(color.blue, 50), title="Line Color", group=grp_style)
lineStyle   = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)
lineWidth   = input.int(2, title="Line Width", minval=1, maxval=5, group=grp_style)
extendLeft  = input.bool(true, title="Extend Lines Left", group=grp_style)
barOffset   = input.int(20, title="Right Offset (bars from current)", minval=0, maxval=400, group=grp_style)

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
// SYMBOL DETECTION
// =================================

bool isNasdaq = str.startswith(syminfo.root, "NQ") or str.startswith(syminfo.root, "MNQ")
bool isGold   = str.startswith(syminfo.root, "GC") or str.startswith(syminfo.root, "MGC")
bool isSupported = isNasdaq or isGold

// NQ: round to nearest 100, zone = round +/- 20  (xx80-xx20)
// GC: round to nearest 10,  zone = round +/- 2   (xx8-xx2)
roundStep = isGold ? 10 : 100
zoneRange = isGold ? 2 : 20

var table warningTable = table.new(position.top_right, 1, 1)
if barstate.isfirst
    if not isSupported
        table.cell(warningTable, 0, 0, "⚠️ WARNING: Designed for NASDAQ (NQ/MNQ) or GOLD (GC/MGC) Futures only", bgcolor=color.new(color.red, 20), text_color=color.white, text_size=size.normal)


// =================================
// LOGIC & DRAWING
// =================================

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
    nearestLevel = math.round(close / roundStep) * roundStep
    offset = math.floor(totalZones / 2)

    array.clear(labeledPrices)

    rightEdge = bar_index + barOffset
    lineExtend = extendLeft ? extend.left : extend.none

    for i = 0 to totalZones - 1
        step = i - offset

        centerLevel = nearestLevel + (step * roundStep)
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

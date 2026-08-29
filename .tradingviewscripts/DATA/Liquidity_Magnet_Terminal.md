<!-- tradingview-pine-id: PUB;76e5740842ca469f8b6aa128754d79f2 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Magnet Terminal

Source: https://www.tradingview.com/script/GXjC5KfC/

## Description

Liquidity Magnet Terminal

Liquidity Magnet Terminal is a volume-weighted liquidity mapping tool that helps traders identify the price levels where the market has historically accumulated the most trading interest — the zones most likely to act as magnets for future price movement.

Most support/resistance tools plot every swing high and low individually, which quickly clutters the chart with dozens of overlapping lines of equal visual weight. This script takes a different approach: it treats pivots as raw data points, clusters the ones sitting close together into unified zones, and weights each zone by the volume that traded at those levels. The result is a small, ranked set of levels — the ones that actually matter — instead of visual noise.

How the zones are built

The script continuously scans for pivot highs and lows using a configurable lookback window, recording the price, volume, and direction (resistance vs. support) of each one. As new pivots form, nearby pivots of the same direction are merged into a single zone using a volume-weighted average — meaning a pivot backed by high volume pulls the zone's price toward itself more strongly than a low-volume pivot would. This mimics how real liquidity accumulates: not at one exact tick, but across a cluster of prices where repeated buying or selling interest has occurred.

Each resulting zone is then scored by its total accumulated volume and normalized against the strongest zone on the chart, producing a relative strength score from 0 to 1. Only the top-ranked zones (configurable count) that clear a minimum strength threshold are kept and drawn — everything else is filtered out automatically.

What you see on the chart

Horizontal lines marking each liquidity zone, color-coded by direction (resistance zones in red, support zones in green), with line length and opacity scaling to zone strength — the strongest, most "magnetic" levels stand out visually without any manual adjustment
A star marker (⭐) highlighting zones in the top strength tier (≥75% relative strength)
A compact terminal-style panel showing current price alongside all active zones, their price levels, and a strength bar for at-a-glance comparison

Inputs

Pivot strength, lookback period, number of zones to display, zone merge tolerance (%), minimum strength filter, line width, and toggles for the panel, price labels, and star markers — all adjustable to fit different timeframes and instruments.

How to use it

Liquidity Magnet Terminal is designed as a contextual map, not a standalone signal generator. Use the ranked zones to anticipate where price is likely to react, get drawn toward, or reverse from — then combine that context with your own entry triggers, market structure analysis, and risk management. Zone strength reflects historical volume clustering; it does not predict direction or guarantee a reaction.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AbaddonPL


//@version=6
indicator(
     "Liquidity Magnet Terminal",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 80)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLen = input.int(
     5,
     "Pivot strength",
     minval = 2,
     maxval = 20)

lookback = input.int(
     300,
     "Lookback",
     minval = 50,
     maxval = 2000)

zones = input.int(
     10,
     "Top zones",
     minval = 5,
     maxval = 20)

mergePct = input.float(
     0.20,
     "Zone merge %",
     minval = 0.01,
     maxval = 1.00,
     step = 0.01)

lineWidth = input.int(
     3,
     "Line width",
     minval = 1,
     maxval = 6)

minStrength = input.float(
     0.05,
     "Minimum strength",
     minval = 0.00,
     maxval = 1.00,
     step = 0.01)

showPanel = input.bool(
     true,
     "Show terminal panel")

showLabels = input.bool(
     true,
     "Show price labels")

showStars = input.bool(
     true,
     "Show strongest ⭐")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

aboveColor = color.red
belowColor = color.green

darkRed = color.red
darkGreen = color.green

panelBg = color.gray
panelRowBg = color.new(color.gray, 80)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float[] pivPrice = array.new_float()
var float[] pivVol   = array.new_float()
var int[]   pivDir   = array.new_int()
var int[]   pivBar   = array.new_int()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float[] zonePrice = array.new_float()
var float[] zonePower = array.new_float()
var int[] zoneDir     = array.new_int()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TOP ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float[] topPrice = array.new_float()
var float[] topPower = array.new_float()
var int[] topDir     = array.new_int()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line[] liqLines = array.new_line()
var label[] liqLabels = array.new_label()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table panel = table.new(
     position.bottom_right,
     3,
     14,
     border_width = 0)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(
     high,
     pivotLen,
     pivotLen)

pivotLow = ta.pivotlow(
     low,
     pivotLen,
     pivotLen)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORE HIGH PIVOT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh)

    array.push(
         pivPrice,
         pivotHigh)

    array.push(
         pivVol,
         nz(volume[pivotLen], 0))

    array.push(
         pivDir,
         1)

    array.push(
         pivBar,
         bar_index - pivotLen)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORE LOW PIVOT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotLow)

    array.push(
         pivPrice,
         pivotLow)

    array.push(
         pivVol,
         nz(volume[pivotLen], 0))

    array.push(
         pivDir,
         -1)

    array.push(
         pivBar,
         bar_index - pivotLen)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REMOVE OLD PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if array.size(pivBar) > 0

    int removeIndex = array.size(pivBar) - 1

    while removeIndex >= 0

        pivotAge =
             bar_index - array.get(
                 pivBar,
                 removeIndex)

        if pivotAge > lookback

            array.remove(
                 pivPrice,
                 removeIndex)

            array.remove(
                 pivVol,
                 removeIndex)

            array.remove(
                 pivDir,
                 removeIndex)

            array.remove(
                 pivBar,
                 removeIndex)

        removeIndex -= 1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUILD ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast

    // CLEAR DRAWINGS

    if array.size(liqLines) > 0

        for i = 0 to array.size(liqLines) - 1

            line.delete(
                 array.get(
                     liqLines,
                     i))

        array.clear(liqLines)


    if array.size(liqLabels) > 0

        for i = 0 to array.size(liqLabels) - 1

            label.delete(
                 array.get(
                     liqLabels,
                     i))

        array.clear(liqLabels)


    // CLEAR ARRAYS

    array.clear(zonePrice)
    array.clear(zonePower)
    array.clear(zoneDir)

    array.clear(topPrice)
    array.clear(topPower)
    array.clear(topDir)


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // CLUSTER PIVOTS
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    pivotCount = array.size(pivPrice)

    if pivotCount > 0

        for i = 0 to pivotCount - 1

            p = array.get(
                 pivPrice,
                 i)

            v = array.get(
                 pivVol,
                 i)

            d = array.get(
                 pivDir,
                 i)

            merged = false

            zoneCount = array.size(zonePrice)

            if zoneCount > 0

                for z = 0 to zoneCount - 1

                    zp = array.get(
                         zonePrice,
                         z)

                    zd = array.get(
                         zoneDir,
                         z)

                    distance =
                         math.abs(
                         p - zp)

                    mergeDistance =
                         math.max(
                         syminfo.mintick * 10,
                         p * mergePct / 100)

                    sameDirection =
                         d == zd

                    if sameDirection and distance <= mergeDistance

                        oldPower =
                             array.get(
                             zonePower,
                             z)

                        newPower =
                             oldPower + v

                        weightedPrice =
                             newPower > 0 ?
                             (zp * oldPower + p * v) / newPower :
                             p

                        array.set(
                             zonePrice,
                             z,
                             weightedPrice)

                        array.set(
                             zonePower,
                             z,
                             newPower)

                        merged := true

                        break

            if not merged

                array.push(
                     zonePrice,
                     p)

                array.push(
                     zonePower,
                     v)

                array.push(
                     zoneDir,
                     d)


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MAX POWER
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    maxPower = 0.0

    zoneCount = array.size(zonePower)

    if zoneCount > 0

        for i = 0 to zoneCount - 1

            maxPower := math.max(
                 maxPower,
                 array.get(
                     zonePower,
                     i))


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SELECT TOP ZONES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    selected = 0

    if maxPower > 0 and array.size(zonePower) > 0

        while selected < zones and array.size(zonePower) > 0

            bestPower = -1.0
            bestIndex = -1

            currentZoneCount =
                 array.size(zonePower)

            for i = 0 to currentZoneCount - 1

                currentPower =
                     array.get(
                     zonePower,
                     i)

                if currentPower > bestPower

                    bestPower := currentPower
                    bestIndex := i

            if bestIndex < 0
                break

            selectedPrice =
                 array.get(
                 zonePrice,
                 bestIndex)

            selectedPower =
                 array.get(
                 zonePower,
                 bestIndex)

            selectedDir =
                 array.get(
                 zoneDir,
                 bestIndex)

            normalizedPower =
                 selectedPower / maxPower

            if normalizedPower >= minStrength

                array.push(
                     topPrice,
                     selectedPrice)

                array.push(
                     topPower,
                     normalizedPower)

                array.push(
                     topDir,
                     selectedDir)

            array.remove(
                 zonePrice,
                 bestIndex)

            array.remove(
                 zonePower,
                 bestIndex)

            array.remove(
                 zoneDir,
                 bestIndex)

            selected += 1


    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DRAW TOP ZONES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    topCount = array.size(topPrice)

    if topCount > 0

        for i = 0 to topCount - 1

            price =
                 array.get(
                 topPrice,
                 i)

            power =
                 array.get(
                 topPower,
                 i)

            dir =
                 array.get(
                 topDir,
                 i)

            lineColor =
                 dir == 1 ?
                 aboveColor :
                 belowColor

            lineLength =
                 int(
                 math.round(
                 25 + power * 100))

            lineStart =
                 math.max(
                 0,
                 bar_index - lineLength)

            transparency =
                 power >= 0.75 ? 0 :
                 power >= 0.50 ? 10 :
                 25

            finalColor =
                 color.new(
                 lineColor,
                 transparency)

            //━━━━━━━━━━━━━━━━━━━━
            // LINE
            //━━━━━━━━━━━━━━━━━━━━

            ln = line.new(
                 x1 = lineStart,
                 y1 = price,
                 x2 = bar_index + 15,
                 y2 = price,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = finalColor,
                 width = lineWidth)

            array.push(
                 liqLines,
                 ln)


            //━━━━━━━━━━━━━━━━━━━━
            // DARK LABEL
            //━━━━━━━━━━━━━━━━━━━━

            if showLabels

                starText =
                     showStars and power >= 0.75 ?
                     " ⭐" :
                     ""

                sideText =
                     dir == 1 ?
                     "SHORT" :
                     "LONG"

                labelText =
                     sideText +
                     starText +
                     "\n" +
                     str.tostring(
                     price,
                     format.mintick)

                labelBg =
                     dir == 1 ?
                     darkRed :
                     darkGreen

                lb = label.new(
                     x = bar_index + 15,
                     y = price,
                     text = labelText,
                     xloc = xloc.bar_index,
                     style = label.style_label_left,
                     textcolor = color.white,
                     color = color.new(
                          labelBg,
                          5),
                     size = size.small)

                array.push(
                     liqLabels,
                     lb)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TERMINAL PANEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast

    // CLEAR PANEL

    for r = 0 to 13

        table.cell(
             panel,
             0,
             r,
             "",
             text_color = color.white,
             bgcolor = color.new(
                 color.black,
                 100))

        table.cell(
             panel,
             1,
             r,
             "",
             text_color = color.white,
             bgcolor = color.new(
                 color.black,
                 100))

        table.cell(
             panel,
             2,
             r,
             "",
             text_color = color.white,
             bgcolor = color.new(
                 color.black,
                 100))


    if showPanel

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // HEADER
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        table.cell(
             panel,
             0,
             0,
             "LIQUIDITY",
             text_color = color.white,
             bgcolor = panelBg)

        table.cell(
             panel,
             1,
             0,
             syminfo.ticker,
             text_color = color.white,
             bgcolor = panelBg)

        table.cell(
             panel,
             2,
             0,
             "MAGNET",
             text_color = color.white,
             bgcolor = panelBg)


        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // PRICE
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        table.cell(
             panel,
             0,
             1,
             "PRICE",
             text_color = color.black,
             bgcolor = panelRowBg)

        table.cell(
             panel,
             1,
             1,
             str.tostring(
                 close,
                 format.mintick),
             text_color = color.black,
             bgcolor = panelRowBg)

        table.cell(
             panel,
             2,
             1,
             "●",
             text_color = color.gray,
             bgcolor = panelRowBg)


        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ZONES
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        topCountPanel =
             array.size(topPrice)

        if topCountPanel > 0

            panelRows =
                 math.min(
                 topCountPanel,
                 11)

            for i = 0 to panelRows - 1

                p =
                     array.get(
                     topPrice,
                     i)

                power =
                     array.get(
                     topPower,
                     i)

                d =
                     array.get(
                     topDir,
                     i)

                bars =
                     int(
                     math.round(
                     power * 10))

                bars :=
                     math.max(
                     1,
                     math.min(
                     10,
                     bars))

                barText = ""

                for b = 0 to 9

                    barText +=
                         b < bars ?
                         "█" :
                         "·"

                zoneColor =
                     d == 1 ?
                     aboveColor :
                     belowColor

                star =
                     showStars and power >= 0.75 ?
                     "⭐" :
                     ""

                // ROW BACKGROUND

                table.cell(
                     panel,
                     0,
                     i + 2,
                     str.tostring(
                         p,
                         format.mintick),
                     text_color = color.black,
                     bgcolor = panelRowBg)

                table.cell(
                     panel,
                     1,
                     i + 2,
                     barText,
                     text_color = zoneColor,
                     bgcolor = panelRowBg)

                table.cell(
                     panel,
                     2,
                     i + 2,
                     star,
                     text_color = color.orange,
                     bgcolor = panelRowBg)
````

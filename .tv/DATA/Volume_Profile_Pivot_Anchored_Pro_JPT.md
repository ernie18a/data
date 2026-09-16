<!-- tradingview-pine-id: PUB;e0965a00ce664c0e81c573c6d29a6e59 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Profile - Pivot Anchored Pro [JPT]

Source: https://www.tradingview.com/script/5VAGJvOe-Volume-Profile-Pivot-Anchored-Pro-JPT/

## Description

🔷 OVERVIEW
Volume Profile – Pivot Anchored Pro [JPT]is an educational volume analysis indicator that automatically creates volume profiles between confirmed swing highs and swing lows. It helps traders visualize where significant trading activity occurred throughout each market swing.

The indicator displays important volume-based levels including the Point of Control (POC) and Value Area High/Low (VAH/VAL), allowing traders to study areas where price may have experienced strong acceptance or rejection.

The indicator is designed to help traders analyze market structure, volume distribution, and key price areas. It does not predict future price movement or guarantee profitable trades.

🔷 FEATURES
• Automatic pivot high and pivot low detection
• Pivot-to-pivot volume profile generation
• Bullish and bearish volume visualization
• POC (Point of Control) level
• VAH (Value Area High) level
• VAL (Value Area Low) level
• High and Low labels for each profile
• Multiple historical volume profiles
• Customizable profile rows
• Adjustable Value Area percentage
• Adjustable profile width
• Customizable colors and display settings
• Clean chart layout with minimal clutter

🔷 HOW IT WORKS
• Detects confirmed swing highs and swing lows.
• Identifies completed price swings between pivot points.
• Calculates the volume distribution across different price levels within each swing.
• Identifies the POC, representing the price level with the highest traded volume.
• Calculates the Value Area, based on the selected Value Area percentage.
• Displays VAH and VAL to define the upper and lower boundaries of the Value Area.
• Draws the volume profile directly on the chart for easy market analysis.

🔷 HOW TO USE
Look for newly completed pivot-to-pivot volume profiles.

Use the POC to identify important high-volume price levels that may act as areas of support, resistance, or price acceptance.

Use VAH and VAL to understand the boundaries of the Value Area and observe how price reacts around these levels.

Compare multiple profiles to study how volume distribution changes from one market swing to another.

Consider combining the indicator with your own price action, market structure, support/resistance, liquidity, and risk management techniques.

🔷 IMPORTANT NOTE
This indicator is intended for educational and analytical purposes only. Volume Profile levels should be treated as reference areas rather than guaranteed support or resistance.

Always perform your own analysis and use appropriate risk management before making any trading decisions.

Volume Profile – Pivot Anchored Pro [JPT] helps you see not only where price moved, but also where the market traded the most volume during each major swing.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Volume Profile - Pivot Anchored Pro [JPT]", overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLen = input.int(14, "Pivot Length", minval=1, maxval=50)
rows = input.int(24, "Profile Rows", minval=5, maxval=60)
valueAreaPercent = input.float(70.0, "Value Area %", minval=50.0, maxval=100.0)

profileWidth = input.int(18, "Profile Width", minval=5, maxval=60)
profilesToKeep = input.int(12, "Profiles To Keep", minval=1, maxval=30)

showPOC = input.bool(true, "Show POC")
showVA = input.bool(true, "Show Value Area")
showLabels = input.bool(true, "Show High / Low Labels")

pocColor = input.color(color.rgb(7, 24, 212), "POC Color")
vaColor = input.color(color.rgb(21, 132, 27), "VAH / VAL Color")

bullColor = input.color(color.rgb(234, 171, 63), "Bull Volume")
bearColor = input.color(color.rgb(90, 100, 115), "Bear Volume")

profileTransparency = input.int(15, "Volume Transparency", minval=0, maxval=90)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box[] allBoxes = array.new_box()
var line[] allLines = array.new_line()
var label[] allLabels = array.new_label()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE OLD DRAWINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

deleteOldObjects() =>

    // Keep approximately the last profilesToKeep * rows boxes.
    int maxBoxes = profilesToKeep * rows

    while array.size(allBoxes) > maxBoxes

        box oldBox = array.shift(allBoxes)

        box.delete(oldBox)

    // Each profile creates up to 3 lines.
    int maxLines = profilesToKeep * 3

    while array.size(allLines) > maxLines

        line oldLine = array.shift(allLines)

        line.delete(oldLine)

    // Two labels per profile.
    int maxLabels = profilesToKeep * 2

    while array.size(allLabels) > maxLabels

        label oldLabel = array.shift(allLabels)

        label.delete(oldLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE PIVOT VOLUME PROFILE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

createProfile(int leftBar, int rightBar) =>

    // Only execute when the segment is valid.
    if rightBar > leftBar

        int barsInProfile = rightBar - leftBar + 1

        // ──────────────────────────────────────────────────────────────
        // Find HIGH / LOW manually.
        // This avoids problems with dynamic ta.highest()/ta.lowest().
        // ──────────────────────────────────────────────────────────────

        float profileHigh = na
        float profileLow = na

        for n = 0 to barsInProfile - 1

            int absoluteBar = leftBar + n

            int offset = bar_index - absoluteBar

            if offset >= 0 and offset <= 4999

                float candleHigh = high[offset]
                float candleLow = low[offset]

                if na(profileHigh) or candleHigh > profileHigh
                    profileHigh := candleHigh

                if na(profileLow) or candleLow < profileLow
                    profileLow := candleLow


        // ──────────────────────────────────────────────────────────────
        // Make sure the range is valid.
        // ──────────────────────────────────────────────────────────────

        if not na(profileHigh) and not na(profileLow)

            float priceRange = profileHigh - profileLow

            if priceRange > 0

                float rowSize = priceRange / rows

                // Volume array
                float[] volumeRows = array.new_float(rows, 0.0)

                // ──────────────────────────────────────────────────────
                // Distribute candle volume into price rows.
                // ──────────────────────────────────────────────────────

                for n = 0 to barsInProfile - 1

                    int absoluteBar = leftBar + n

                    int offset = bar_index - absoluteBar

                    if offset >= 0 and offset <= 4999

                        float candleHigh = high[offset]
                        float candleLow = low[offset]
                        float candleVolume = volume[offset]

                        float candleRange = candleHigh - candleLow

                        if candleRange <= 0
                            candleRange := syminfo.mintick

                        for r = 0 to rows - 1

                            float rowLow = profileLow + r * rowSize
                            float rowHigh = rowLow + rowSize

                            float overlapHigh = math.min(candleHigh, rowHigh)
                            float overlapLow = math.max(candleLow, rowLow)

                            float overlap = overlapHigh - overlapLow

                            if overlap > 0

                                float portion = overlap / candleRange

                                float addedVolume = candleVolume * portion

                                float oldVolume = array.get(volumeRows, r)

                                array.set(
                                     volumeRows,
                                     r,
                                     oldVolume + addedVolume)


                // ──────────────────────────────────────────────────────
                // Find POC.
                // ──────────────────────────────────────────────────────

                float maxVolume = 0.0
                int pocRow = 0

                for r = 0 to rows - 1

                    float rowVolume = array.get(volumeRows, r)

                    if rowVolume > maxVolume

                        maxVolume := rowVolume
                        pocRow := r


                float pocPrice =
                     profileLow +
                     (pocRow + 0.5) * rowSize


                // ──────────────────────────────────────────────────────
                // Calculate Value Area.
                // ──────────────────────────────────────────────────────

                float totalVolume = 0.0

                for r = 0 to rows - 1
                    totalVolume += array.get(volumeRows, r)

                float targetVolume =
                     totalVolume * valueAreaPercent / 100.0

                float currentVolume =
                     array.get(volumeRows, pocRow)

                int vaLowRow = pocRow
                int vaHighRow = pocRow

                int safety = 0

                while currentVolume < targetVolume and safety < rows

                    safety += 1

                    float volumeBelow = -1.0
                    float volumeAbove = -1.0

                    if vaLowRow > 0
                        volumeBelow =
                             array.get(
                                 volumeRows,
                                 vaLowRow - 1)

                    if vaHighRow < rows - 1
                        volumeAbove =
                             array.get(
                                 volumeRows,
                                 vaHighRow + 1)


                    if volumeAbove >= volumeBelow and
                       vaHighRow < rows - 1

                        vaHighRow += 1

                        currentVolume +=
                             array.get(
                                 volumeRows,
                                 vaHighRow)

                    else if vaLowRow > 0

                        vaLowRow -= 1

                        currentVolume +=
                             array.get(
                                 volumeRows,
                                 vaLowRow)

                    else
                        break


                float vah =
                     profileLow +
                     (vaHighRow + 1) * rowSize

                float val =
                     profileLow +
                     vaLowRow * rowSize


                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // DRAW VOLUME HISTOGRAM
                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                for r = 0 to rows - 1

                    float rowVolume =
                         array.get(volumeRows, r)

                    if rowVolume > 0 and maxVolume > 0

                        float widthRatio =
                             rowVolume / maxVolume

                        int barWidth =
                             math.max(
                                 1,
                                 int(
                                     math.round(
                                         widthRatio *
                                         profileWidth)))


                        int x1 = rightBar

                        int x2 =
                             rightBar + barWidth


                        float y1 =
                             profileLow +
                             r * rowSize

                        float y2 =
                             y1 + rowSize


                        bool insideVA =
                             r >= vaLowRow and
                             r <= vaHighRow


                        color volumeColor =
                             insideVA ?
                             color.new(
                                 bullColor,
                                 profileTransparency) :
                             color.new(
                                 bearColor,
                                 profileTransparency + 20)


                        box newBox =
                             box.new(
                                 left=x1,
                                 top=y2,
                                 right=x2,
                                 bottom=y1,
                                 xloc=xloc.bar_index,
                                 bgcolor=volumeColor,
                                 border_color=color.new(
                                     volumeColor,
                                     100))


                        array.push(allBoxes, newBox)


                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // POC
                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                if showPOC

                    line pocLine =
                         line.new(
                             x1=leftBar,
                             y1=pocPrice,
                             x2=rightBar + profileWidth,
                             y2=pocPrice,
                             xloc=xloc.bar_index,
                             color=pocColor,
                             width=3)

                    array.push(allLines, pocLine)


                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // VALUE AREA HIGH / LOW
                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                if showVA

                    line vahLine =
                         line.new(
                             x1=leftBar,
                             y1=vah,
                             x2=rightBar + profileWidth,
                             y2=vah,
                             xloc=xloc.bar_index,
                             color=vaColor,
                             width=1)

                    line valLine =
                         line.new(
                             x1=leftBar,
                             y1=val,
                             x2=rightBar + profileWidth,
                             y2=val,
                             xloc=xloc.bar_index,
                             color=vaColor,
                             width=1)

                    array.push(allLines, vahLine)
                    array.push(allLines, valLine)


                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // HIGH / LOW LABELS
                //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                if showLabels

                    label highLabel =
                         label.new(
                             x=rightBar,
                             y=profileHigh,
                             text="High\n" +
                                  str.tostring(
                                      profileHigh,
                                      format.mintick),
                             xloc=xloc.bar_index,
                             style=label.style_label_down,
                             color=color.rgb(75, 105, 150),
                             textcolor=color.white,
                             size=size.tiny)

                    label lowLabel =
                         label.new(
                             x=rightBar,
                             y=profileLow,
                             text="Low\n" +
                                  str.tostring(
                                      profileLow,
                                      format.mintick),
                             xloc=xloc.bar_index,
                             style=label.style_label_up,
                             color=color.rgb(75, 105, 150),
                             textcolor=color.white,
                             size=size.tiny)

                    array.push(allLabels, highLabel)
                    array.push(allLabels, lowLabel)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(
     high,
     pivotLen,
     pivotLen)

pivotLow = ta.pivotlow(
     low,
     pivotLen,
     pivotLen)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LAST PIVOT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastPivotBar = na
var float lastPivotPrice = na
var int lastPivotType = 0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT HIGH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh)

    int currentPivotBar =
         bar_index - pivotLen

    // Only accept alternating pivots.
    bool validPivot =
         lastPivotType != 1

    if validPivot

        if not na(lastPivotBar)

            createProfile(
                 lastPivotBar,
                 currentPivotBar)

        lastPivotBar := currentPivotBar
        lastPivotPrice := pivotHigh
        lastPivotType := 1

        deleteOldObjects()


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotLow)

    int currentPivotBar =
         bar_index - pivotLen

    bool validPivot =
         lastPivotType != -1

    if validPivot

        if not na(lastPivotBar)

            createProfile(
                 lastPivotBar,
                 currentPivotBar)

        lastPivotBar := currentPivotBar
        lastPivotPrice := pivotLow
        lastPivotType := -1

        deleteOldObjects()
````

# Hierarchical High Low Structure

- url: https://www.tradingview.com/script/hsm9CVxP-Hierarchical-High-Low-Structure/
- type: indicator
- pine_id: PUB;3536780fdca14270af46f1d4701a2794
- version: 1.0

## Description

This indicator identifies hierarchical market structure using three levels of swing highs and lows:

* **SH / SL** — Short-Term High / Low
* **MH / ML** — Mid-Term High / Low
* **LH / LL** — Long-Term High / Low

Each level is derived from the previous one using the same symmetrical pivot logic. The script also connects confirmed MH/LH and ML/LL points with an alternating structure line, keeping the more extreme point when multiple highs or lows appear consecutively.

Swing points are confirmed only after the required right-side structure forms, so labels are plotted back on the original pivot bar. This indicator is intended for market structure analysis, not as a standalone trading signal.

## Source Code

````pine
//@version=6
indicator(
     "Hierarchical High Low Structure",
     shorttitle = "SH MH LH / SL ML LL",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500
)

//====================================================
// Inputs
//====================================================

int recentBars = input.int(
     200,
     "Display Recent X Bars",
     minval = 10,
     maxval = 500
)

bool showShortTerm = input.bool(
     true,
     "Show SH / SL"
)

bool showMidTerm = input.bool(
     true,
     "Show MH / ML"
)

bool showLongTerm = input.bool(
     true,
     "Show LH / LL"
)

bool showStructureLines = input.bool(
     true,
     "Connect MH/LH and ML/LL"
)

color shColor = input.color(
     color.red,
     "SH Color"
)

color mhColor = input.color(
     color.orange,
     "MH Color"
)

color lhColor = input.color(
     color.purple,
     "LH Color"
)

color slColor = input.color(
     color.green,
     "SL Color"
)

color mlColor = input.color(
     color.teal,
     "ML Color"
)

color llColor = input.color(
     color.blue,
     "LL Color"
)

color labelTextColor = input.color(
     color.white,
     "Label Text Color"
)

color structureLineColor = input.color(
     color.gray,
     "Structure Line Color"
)

int structureLineWidth = input.int(
     2,
     "Structure Line Width",
     minval = 1,
     maxval = 5
)

// Left boundary of the display window
int cutoffBar = math.max(
     0,
     last_bar_index - recentBars + 1
)

//====================================================
// High structure storage
//
// shLevels:
// 1 = Short-Term High
// 2 = Mid-Term High
// 3 = Long-Term High
//====================================================

var array<int> shBars = array.new<int>()
var array<int> shTimes = array.new<int>()
var array<float> shPrices = array.new<float>()
var array<int> shLevels = array.new<int>()

// Stores indices from the SH arrays that qualify as MH
var array<int> mhIndices = array.new<int>()

//====================================================
// Low structure storage
//
// slLevels:
// 1 = Short-Term Low
// 2 = Mid-Term Low
// 3 = Long-Term Low
//====================================================

var array<int> slBars = array.new<int>()
var array<int> slTimes = array.new<int>()
var array<float> slPrices = array.new<float>()
var array<int> slLevels = array.new<int>()

// Stores indices from the SL arrays that qualify as ML
var array<int> mlIndices = array.new<int>()

//====================================================
// Drawing object storage
//====================================================

var array<label> drawnLabels = array.new<label>()
var array<line> drawnLines = array.new<line>()

//====================================================
// Detect Short-Term High
//====================================================

bool newShortTermHigh = barstate.isconfirmed and bar_index >= 2 and high[1] > high[2] and high[1] > high

if newShortTermHigh

    // Add the newly confirmed SH
    array.push(shBars, bar_index - 1)
    array.push(shTimes, time[1])
    array.push(shPrices, high[1])
    array.push(shLevels, 1)

    int shCount = array.size(shPrices)

    // Evaluate the latest three SH points
    if shCount >= 3

        int leftShIndex = shCount - 3
        int middleShIndex = shCount - 2
        int rightShIndex = shCount - 1

        float leftShPrice = array.get(
             shPrices,
             leftShIndex
        )

        float middleShPrice = array.get(
             shPrices,
             middleShIndex
        )

        float rightShPrice = array.get(
             shPrices,
             rightShIndex
        )

        // The middle SH becomes MH when it is higher
        // than the SH immediately before and after it
        bool becomesMidTermHigh = middleShPrice > leftShPrice and middleShPrice > rightShPrice

        if becomesMidTermHigh

            array.set(
                 shLevels,
                 middleShIndex,
                 2
            )

            array.push(
                 mhIndices,
                 middleShIndex
            )

            int mhCount = array.size(mhIndices)

            // Evaluate the latest three MH points
            if mhCount >= 3

                int leftMhPosition = mhCount - 3
                int middleMhPosition = mhCount - 2
                int rightMhPosition = mhCount - 1

                int leftMhIndex = array.get(
                     mhIndices,
                     leftMhPosition
                )

                int middleMhIndex = array.get(
                     mhIndices,
                     middleMhPosition
                )

                int rightMhIndex = array.get(
                     mhIndices,
                     rightMhPosition
                )

                float leftMhPrice = array.get(
                     shPrices,
                     leftMhIndex
                )

                float middleMhPrice = array.get(
                     shPrices,
                     middleMhIndex
                )

                float rightMhPrice = array.get(
                     shPrices,
                     rightMhIndex
                )

                // The middle MH becomes LH when it is higher
                // than the MH immediately before and after it
                bool becomesLongTermHigh = middleMhPrice > leftMhPrice and middleMhPrice > rightMhPrice

                if becomesLongTermHigh
                    array.set(
                         shLevels,
                         middleMhIndex,
                         3
                    )

//====================================================
// Detect Short-Term Low
//====================================================

bool newShortTermLow = barstate.isconfirmed and bar_index >= 2 and low[1] < low[2] and low[1] < low

if newShortTermLow

    // Add the newly confirmed SL
    array.push(slBars, bar_index - 1)
    array.push(slTimes, time[1])
    array.push(slPrices, low[1])
    array.push(slLevels, 1)

    int slCount = array.size(slPrices)

    // Evaluate the latest three SL points
    if slCount >= 3

        int leftSlIndex = slCount - 3
        int middleSlIndex = slCount - 2
        int rightSlIndex = slCount - 1

        float leftSlPrice = array.get(
             slPrices,
             leftSlIndex
        )

        float middleSlPrice = array.get(
             slPrices,
             middleSlIndex
        )

        float rightSlPrice = array.get(
             slPrices,
             rightSlIndex
        )

        // The middle SL becomes ML when it is lower
        // than the SL immediately before and after it
        bool becomesMidTermLow = middleSlPrice < leftSlPrice and middleSlPrice < rightSlPrice

        if becomesMidTermLow

            array.set(
                 slLevels,
                 middleSlIndex,
                 2
            )

            array.push(
                 mlIndices,
                 middleSlIndex
            )

            int mlCount = array.size(mlIndices)

            // Evaluate the latest three ML points
            if mlCount >= 3

                int leftMlPosition = mlCount - 3
                int middleMlPosition = mlCount - 2
                int rightMlPosition = mlCount - 1

                int leftMlIndex = array.get(
                     mlIndices,
                     leftMlPosition
                )

                int middleMlIndex = array.get(
                     mlIndices,
                     middleMlPosition
                )

                int rightMlIndex = array.get(
                     mlIndices,
                     rightMlPosition
                )

                float leftMlPrice = array.get(
                     slPrices,
                     leftMlIndex
                )

                float middleMlPrice = array.get(
                     slPrices,
                     middleMlIndex
                )

                float rightMlPrice = array.get(
                     slPrices,
                     rightMlIndex
                )

                // The middle ML becomes LL when it is lower
                // than the ML immediately before and after it
                bool becomesLongTermLow = middleMlPrice < leftMlPrice and middleMlPrice < rightMlPrice

                if becomesLongTermLow
                    array.set(
                         slLevels,
                         middleMlIndex,
                         3
                    )

//====================================================
// Redraw labels and structure lines
//====================================================

if barstate.islast

    // Delete labels created during the previous redraw
    while array.size(drawnLabels) > 0
        label oldLabel = array.pop(drawnLabels)
        label.delete(oldLabel)

    // Delete lines created during the previous redraw
    while array.size(drawnLines) > 0
        line oldLine = array.pop(drawnLines)
        line.delete(oldLine)

    //================================================
    // Draw high labels
    //================================================

    int highCount = array.size(shBars)

    if highCount > 0

        for highIndex = 0 to highCount - 1

            int pivotBar = array.get(
                 shBars,
                 highIndex
            )

            if pivotBar >= cutoffBar

                float pivotPrice = array.get(
                     shPrices,
                     highIndex
                )

                int pivotLevel = array.get(
                     shLevels,
                     highIndex
                )

                label highLabel = na

                // Display the highest enabled classification
                if pivotLevel == 3 and showLongTerm

                    highLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "LH",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_down,
                         color = lhColor,
                         textcolor = labelTextColor,
                         size = size.normal,
                         tooltip = "Long-Term High"
                    )

                else if pivotLevel >= 2 and showMidTerm

                    highLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "MH",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_down,
                         color = mhColor,
                         textcolor = labelTextColor,
                         size = size.small,
                         tooltip = "Mid-Term High"
                    )

                else if showShortTerm

                    highLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "SH",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_down,
                         color = shColor,
                         textcolor = labelTextColor,
                         size = size.tiny,
                         tooltip = "Short-Term High"
                    )

                if not na(highLabel)
                    array.push(
                         drawnLabels,
                         highLabel
                    )

    //================================================
    // Draw low labels
    //================================================

    int lowCount = array.size(slBars)

    if lowCount > 0

        for lowIndex = 0 to lowCount - 1

            int pivotBar = array.get(
                 slBars,
                 lowIndex
            )

            if pivotBar >= cutoffBar

                float pivotPrice = array.get(
                     slPrices,
                     lowIndex
                )

                int pivotLevel = array.get(
                     slLevels,
                     lowIndex
                )

                label lowLabel = na

                // Display the highest enabled classification
                if pivotLevel == 3 and showLongTerm

                    lowLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "LL",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_up,
                         color = llColor,
                         textcolor = labelTextColor,
                         size = size.normal,
                         tooltip = "Long-Term Low"
                    )

                else if pivotLevel >= 2 and showMidTerm

                    lowLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "ML",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_up,
                         color = mlColor,
                         textcolor = labelTextColor,
                         size = size.small,
                         tooltip = "Mid-Term Low"
                    )

                else if showShortTerm

                    lowLabel := label.new(
                         x = pivotBar,
                         y = pivotPrice,
                         text = "SL",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_up,
                         color = slColor,
                         textcolor = labelTextColor,
                         size = size.tiny,
                         tooltip = "Short-Term Low"
                    )

                if not na(lowLabel)
                    array.push(
                         drawnLabels,
                         lowLabel
                    )

    //================================================
    // Draw alternating MH/LH and ML/LL structure
    //================================================

    if showStructureLines

        int mhCount = array.size(mhIndices)
        int mlCount = array.size(mlIndices)

        int highPosition = 0
        int lowPosition = 0

        // Active structure point:
        //  1 = high
        // -1 = low
        //  0 = not initialized
        int activeType = 0
        int activeBar = na
        int activeTime = na
        float activePrice = na

        // The opposite point immediately before the active point
        int anchorBar = na
        int anchorTime = na
        float anchorPrice = na

        // The line segment ending at the active point
        line activeSegment = na

        // Merge MH and ML arrays in chronological order
        while highPosition < mhCount or lowPosition < mlCount

            bool takeHigh = false

            if highPosition < mhCount and lowPosition < mlCount

                int nextMhIndex = array.get(
                     mhIndices,
                     highPosition
                )

                int nextMlIndex = array.get(
                     mlIndices,
                     lowPosition
                )

                int nextMhBar = array.get(
                     shBars,
                     nextMhIndex
                )

                int nextMlBar = array.get(
                     slBars,
                     nextMlIndex
                )

                if nextMhBar < nextMlBar
                    takeHigh := true

                else if nextMlBar < nextMhBar
                    takeHigh := false

                else
                    // If both structures occur on the same bar,
                    // process the direction opposite to the active point first
                    if activeType == 1
                        takeHigh := false
                    else
                        takeHigh := true

            else if highPosition < mhCount
                takeHigh := true

            else
                takeHigh := false

            int pointType = 0
            int pointBar = na
            int pointTime = na
            float pointPrice = na

            if takeHigh

                int mhIndex = array.get(
                     mhIndices,
                     highPosition
                )

                pointType := 1

                pointBar := array.get(
                     shBars,
                     mhIndex
                )

                pointTime := array.get(
                     shTimes,
                     mhIndex
                )

                pointPrice := array.get(
                     shPrices,
                     mhIndex
                )

                highPosition += 1

            else

                int mlIndex = array.get(
                     mlIndices,
                     lowPosition
                )

                pointType := -1

                pointBar := array.get(
                     slBars,
                     mlIndex
                )

                pointTime := array.get(
                     slTimes,
                     mlIndex
                )

                pointPrice := array.get(
                     slPrices,
                     mlIndex
                )

                lowPosition += 1

            // Initialize the first structure point
            if activeType == 0

                activeType := pointType
                activeBar := pointBar
                activeTime := pointTime
                activePrice := pointPrice

            // An opposite structure point creates a new segment
            else if pointType != activeType

                anchorBar := activeBar
                anchorTime := activeTime
                anchorPrice := activePrice

                activeType := pointType
                activeBar := pointBar
                activeTime := pointTime
                activePrice := pointPrice

                activeSegment := na

                // Draw when the new endpoint is inside the display window
                if activeBar >= cutoffBar

                    activeSegment := line.new(
                         x1 = anchorTime,
                         y1 = anchorPrice,
                         x2 = activeTime,
                         y2 = activePrice,
                         xloc = xloc.bar_time,
                         extend = extend.none,
                         color = structureLineColor,
                         style = line.style_solid,
                         width = structureLineWidth
                    )

                    array.push(
                         drawnLines,
                         activeSegment
                    )

            // Consecutive points in the same direction
            else

                bool moreExtreme = false

                if pointType == 1
                    moreExtreme := pointPrice > activePrice
                else
                    moreExtreme := pointPrice < activePrice

                if moreExtreme

                    activeBar := pointBar
                    activeTime := pointTime
                    activePrice := pointPrice

                    // Move the existing segment endpoint
                    if not na(activeSegment)

                        line.set_xy2(
                             activeSegment,
                             activeTime,
                             activePrice
                        )

                    // Create the segment if the previous endpoint was
                    // outside the display window and the replacement is inside
                    else if activeBar >= cutoffBar and not na(anchorBar)

                        activeSegment := line.new(
                             x1 = anchorTime,
                             y1 = anchorPrice,
                             x2 = activeTime,
                             y2 = activePrice,
                             xloc = xloc.bar_time,
                             extend = extend.none,
                             color = structureLineColor,
                             style = line.style_solid,
                             width = structureLineWidth
                        )

                        array.push(
                             drawnLines,
                             activeSegment
                        )
````

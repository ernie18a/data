# Gap Map

- url: https://www.tradingview.com/script/ZTvb9YQF-Gap-Map/
- type: indicator
- pine_id: PUB;e5017eeced1045c3b361c1c5b6b04a40
- version: 1.0

## Description

Gap Map is a price-action mapping tool that identifies true price gaps and tracks them as live zones on the chart.

A true gap is defined as:

* Gap Up: the current open is above the previous bar’s high.
* Gap Down: the current open is below the previous bar’s low.

This means the script does not draw every close-to-open gap. It only maps gaps where the new bar opens completely beyond the previous bar’s range.

1. Core Idea

Price gaps can leave visible areas on the chart where no trading occurred between two consecutive bars.

Gap Map highlights these areas as zones and keeps them active until price fully fills the gap.

The goal is to help users visually track:

* Open true gaps
* Partially filled gaps
* Fully filled gaps
* High-volume gap zones
* Historical fill behavior on the current chart

This is a mapping and analysis tool. It is not a buy/sell indicator and not a trading strategy.

2. What the Indicator Draws

When a valid true gap appears, the script draws a zone between the previous bar’s range and the current open.

For a Gap Up, the zone is drawn between:

Previous high → Current open

For a Gap Down, the zone is drawn between:

Current open → Previous low

The zone remains active until price fully fills the gap.

3. Gap Size Filter

The script includes a minimum gap size filter based on ATR.

Gap size is measured in ATR units:

Gap size / Previous ATR

This helps filter out very small gaps that may not be visually or analytically useful.

Users can reduce the threshold to show more gaps or increase it to focus only on larger gaps.

4. Partial Fill Behavior

The script can optionally shrink a gap zone when price partially fills it.

When this option is enabled, the zone adjusts to show only the remaining unfilled part of the gap.

This helps users see whether a gap is still fully open, partially filled, or already closed.

5. Full Gap Fill

A gap is considered fully filled when price reaches the full-fill level.

For a Gap Up, the gap is filled when price trades back to the previous high.

For a Gap Down, the gap is filled when price trades back to the previous low.

Filled zones can either be removed from the chart or kept as faded historical zones, depending on the user’s settings.

6. High-Volume Gaps

The script compares the gap bar’s volume with its average volume.

If the gap appears with volume above the selected relative-volume threshold, it is marked with a highlighted border.

These high-volume gaps are treated as breakaway candidates for review.

This does not mean the gap cannot fill. It only means the gap occurred with stronger-than-usual volume and may deserve additional attention.

7. Optional Statistics Table

The optional statistics table summarizes gap behavior on the current chart.

It can show:

* Number of true gap-up zones
* Number of true gap-down zones
* Percentage filled so far
* Median bars to fill
* Number of open gaps now
* High-volume gap fill statistics

The table is intended as historical context for the current symbol and timeframe.

It should not be interpreted as a forecast that future gaps must behave the same way.

8. How to Use

A practical workflow:

1. Add the indicator to a clean chart.

2. Keep the default ATR filter first.

3. Review open gap zones.

4. Check whether price is approaching a gap zone.

5. Use partial-fill behavior to monitor how much of the gap remains open.

6. Turn on the statistics table if you want historical fill context.

7. Combine the gap map with trend, volume, support/resistance, and broader market context.

8. Best Use Cases

Gap Map is most useful for markets that can create real gaps, such as:

* Stocks
* ETFs
* Indices
* Session-based futures
* Markets with clear open/close sessions

It is less meaningful on continuously traded markets where true session gaps are rare.

10. Important Notes

This script maps true gaps only.

It does not draw every close-to-open difference.

It does not predict that a gap must fill.

It does not provide entry or exit signals.

It does not measure order flow.

It does not execute trades.

High-volume gap highlighting is for visual review only, not a confirmation of direction.

11. Alerts

The script includes alert conditions for:

* New true gap up
* New true gap down
* Gap filled

Alerts are informational only. They do not confirm future price movement.

12. Limitations

Gap behavior can vary by symbol, timeframe, volatility regime, market structure, earnings events, news events, and liquidity conditions.

A gap zone can remain open for a long time.

A gap can be partially filled and then price can continue in the original direction.

Large high-volume gaps may behave differently from small low-volume gaps.

Historical fill statistics are calculated from the current chart’s own history and should be treated as context, not a guarantee.

13. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Gap Map
// ============================================================================
// Gap Map draws true price gaps as live zones on the chart.
//
// A true gap is defined as:
// - Gap Up:   current open is above the previous bar's high.
// - Gap Down: current open is below the previous bar's low.
//
// The script tracks each unfilled gap zone until price fully fills it.
// It can also shrink the zone as price partially fills the gap.
//
// Important:
// - This script maps true gaps only.
// - It does not draw every close-to-open gap.
// - Gap zones are analytical reference areas, not automatic trade signals.
// - High-volume gaps are highlighted as breakaway candidates for review.
// - The script does not predict that a gap must fill.
// - It is not a strategy and does not execute trades.
// ============================================================================

indicator(
     "Gap Map",
     shorttitle = "GapMap",
     overlay = true,
     max_boxes_count = 500)

// ============================================================================
// Inputs
// ============================================================================

grpDetection = "1) Detection"

minSizeAtr = input.float(
     0.30,
     "Minimum gap size (ATR units)",
     minval = 0.0,
     step = 0.10,
     group = grpDetection,
     tooltip = "Only draw true gaps that are at least this large, measured in ATR units of the bar before the gap. Set to 0 to draw every true gap.")

atrLen = input.int(
     14,
     "ATR length",
     minval = 1,
     group = grpDetection,
     tooltip = "ATR period used to normalize gap size. Gap size is measured as gap distance divided by previous-bar ATR.")

rvolLen = input.int(
     20,
     "Volume average length",
     minval = 1,
     group = grpDetection,
     tooltip = "Lookback used for average volume. Gap-day volume is compared with the prior average volume to classify high-volume gaps.")

rvolThresh = input.float(
     1.50,
     "High-volume threshold (x avg)",
     minval = 0.10,
     step = 0.10,
     group = grpDetection,
     tooltip = "Gap-day volume at or above this multiple of prior average volume marks the gap as high-volume. These are highlighted as breakaway candidates for review.")

confirmEvents = input.bool(
     true,
     "Confirm gap events on candle close",
     group = grpDetection,
     tooltip = "ON by default. New gaps, partial fills, and full fills update only after candle close. This keeps zones more stable during the live candle.")

maxOpenGaps = input.int(
     100,
     "Max open gaps tracked",
     minval = 10,
     maxval = 250,
     group = grpDetection,
     tooltip = "Maximum number of unfilled gap zones kept active at one time. When exceeded, the oldest active zone is removed.")

grpVisual = "2) Visuals"

upGapColor = input.color(
     color.new(#26A69A, 82),
     "Gap up zone",
     group = grpVisual,
     tooltip = "Fill color for gap-up zones. A gap-up zone is the void between previous high and current open.")

downGapColor = input.color(
     color.new(#EF5350, 82),
     "Gap down zone",
     group = grpVisual,
     tooltip = "Fill color for gap-down zones. A gap-down zone is the void between current open and previous low.")

highVolumeBorderColor = input.color(
     color.orange,
     "High-volume border",
     group = grpVisual,
     tooltip = "Border color used for high-volume gap zones. These are highlighted as breakaway candidates for review.")

showSizeLabel = input.bool(
     true,
     "Show gap size text",
     group = grpVisual,
     tooltip = "Shows the gap size in ATR units inside each zone. High-volume gaps also show HV.")

shrinkPartial = input.bool(
     true,
     "Shrink zone on partial fill",
     group = grpVisual,
     tooltip = "When price partially fills a gap without fully closing it, the zone shrinks to show the remaining unfilled area.")

keepFilled = input.bool(
     false,
     "Keep filled zones faded",
     group = grpVisual,
     tooltip = "OFF by default to reduce clutter. When ON, filled zones remain on the chart in a faded color.")

fadeTransp = input.int(
     94,
     "Filled zone transparency",
     minval = 60,
     maxval = 99,
     group = grpVisual,
     active = keepFilled,
     tooltip = "Transparency used for filled zones when Keep filled zones faded is enabled.")

grpTable = "3) Optional Stats Table"

showTable = input.bool(
     false,
     "Show stats table",
     group = grpTable,
     tooltip = "OFF by default to keep the chart clean. Turn ON to show gap counts, fill percentage, median bars to fill, and open gaps.")

tablePosInput = input.string(
     "Top Right",
     "Table position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group = grpTable,
     active = showTable)

tableSizeInput = input.string(
     "Small",
     "Table text size",
     options = ["Tiny", "Small", "Normal"],
     group = grpTable,
     active = showTable)

// ============================================================================
// Helper functions
// ============================================================================

f_table_position(string pos) =>
    pos == "Top Right" ? position.top_right :
     pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_table_size(string sizeText) =>
    sizeText == "Tiny" ? size.tiny :
     sizeText == "Normal" ? size.normal :
     size.small

f_pct(float value) =>
    na(value) ? "-" : str.tostring(value, "0.0") + "%"

f_med_string(array<int> values) =>
    array.size(values) > 0 ? str.tostring(array.median(values), "0") : "-"

// ============================================================================
// Series
// ============================================================================

atrValue = ta.atr(atrLen)

volumeAverage = ta.sma(volume, rvolLen)

volumeAveragePrior = volumeAverage[1]

// ============================================================================
// Active gap zone storage
// ============================================================================

var box[] gapBoxes = array.new<box>()
var float[] gapFillLevels = array.new<float>()
var bool[] gapIsUp = array.new<bool>()
var bool[] gapHighVolume = array.new<bool>()
var int[] gapStartBars = array.new<int>()

// ============================================================================
// Cumulative chart-history statistics
// ============================================================================

var int totalUpGaps = 0
var int totalDownGaps = 0
var int filledUpGaps = 0
var int filledDownGaps = 0

var int totalHighVolumeGaps = 0
var int filledHighVolumeGaps = 0

var int[] fillBarsUp = array.new<int>()
var int[] fillBarsDown = array.new<int>()

// ============================================================================
// Event flags
// ============================================================================

bool newGapUp = false
bool newGapDown = false
bool gapFilledNow = false

bool eventsAllowed = not confirmEvents or barstate.isconfirmed

// ============================================================================
// Detect new true gaps
// ============================================================================

bool hasPriorBar = not na(high[1]) and not na(low[1]) and not na(open)

bool rawGapUp = hasPriorBar and open > high[1]

bool rawGapDown = hasPriorBar and open < low[1]

if eventsAllowed and (rawGapUp or rawGapDown) and not na(atrValue[1]) and atrValue[1] > 0.0
    float gapSize = rawGapUp ? open - high[1] : low[1] - open

    float gapSizeAtr = gapSize / atrValue[1]

    if gapSizeAtr >= minSizeAtr
        bool isHighVolume = not na(volumeAveragePrior) and volumeAveragePrior > 0.0 and volume / volumeAveragePrior >= rvolThresh

        float zoneTop = rawGapUp ? open : low[1]
        float zoneBottom = rawGapUp ? high[1] : open

        color baseColor = rawGapUp ? upGapColor : downGapColor

        color borderColor = isHighVolume ? highVolumeBorderColor : color.new(baseColor, 35)

        string labelText = showSizeLabel ? str.tostring(gapSizeAtr, "0.0") + " ATR" + (isHighVolume ? " HV" : "") : ""

        box gapBox = box.new(
             bar_index,
             zoneTop,
             bar_index,
             zoneBottom,
             border_color = borderColor,
             border_width = isHighVolume ? 2 : 1,
             bgcolor = baseColor,
             text = labelText,
             text_size = size.tiny,
             text_color = color.new(chart.fg_color, 35),
             text_halign = text.align_left,
             text_valign = text.align_center)

        array.push(gapBoxes, gapBox)
        array.push(gapFillLevels, rawGapUp ? high[1] : low[1])
        array.push(gapIsUp, rawGapUp)
        array.push(gapHighVolume, isHighVolume)
        array.push(gapStartBars, bar_index)

        totalUpGaps += rawGapUp ? 1 : 0
        totalDownGaps += rawGapUp ? 0 : 1
        totalHighVolumeGaps += isHighVolume ? 1 : 0

        newGapUp := rawGapUp
        newGapDown := rawGapDown

// ============================================================================
// Update active zones
// ============================================================================

if eventsAllowed and array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        box activeBox = array.get(gapBoxes, i)

        bool isUpGap = array.get(gapIsUp, i)

        float fillLevel = array.get(gapFillLevels, i)

        box.set_right(activeBox, bar_index)

        bool fullFill = isUpGap ? low <= fillLevel : high >= fillLevel

        if fullFill
            int barsToFill = bar_index - array.get(gapStartBars, i)

            if isUpGap
                filledUpGaps += 1
                array.push(fillBarsUp, barsToFill)
            else
                filledDownGaps += 1
                array.push(fillBarsDown, barsToFill)

            if array.get(gapHighVolume, i)
                filledHighVolumeGaps += 1

            if keepFilled
                box.set_bgcolor(activeBox, color.new(color.gray, fadeTransp))
                box.set_border_color(activeBox, color.new(color.gray, fadeTransp))
                box.set_text_color(activeBox, color.new(color.gray, fadeTransp))
            else
                box.delete(activeBox)

            array.remove(gapBoxes, i)
            array.remove(gapFillLevels, i)
            array.remove(gapIsUp, i)
            array.remove(gapHighVolume, i)
            array.remove(gapStartBars, i)

            gapFilledNow := true

        else if shrinkPartial
            if isUpGap and low < box.get_top(activeBox) and low > fillLevel
                box.set_top(activeBox, low)
            else if not isUpGap and high > box.get_bottom(activeBox) and high < fillLevel
                box.set_bottom(activeBox, high)

// ============================================================================
// Extend zones during live candle without changing fill state
// ============================================================================

if not eventsAllowed and array.size(gapBoxes) > 0
    for i = 0 to array.size(gapBoxes) - 1
        box activeBox = array.get(gapBoxes, i)
        box.set_right(activeBox, bar_index)

// ============================================================================
// Trim oldest open zones
// ============================================================================

if array.size(gapBoxes) > maxOpenGaps
    box oldestBox = array.shift(gapBoxes)
    box.delete(oldestBox)

    array.shift(gapFillLevels)
    array.shift(gapIsUp)
    array.shift(gapHighVolume)
    array.shift(gapStartBars)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     newGapUp,
     title = "New gap up",
     message = "Gap Map: new true gap-up zone opened on {{ticker}} {{interval}}")

alertcondition(
     newGapDown,
     title = "New gap down",
     message = "Gap Map: new true gap-down zone opened on {{ticker}} {{interval}}")

alertcondition(
     gapFilledNow,
     title = "Gap filled",
     message = "Gap Map: a true gap zone was fully filled on {{ticker}} {{interval}}")

// ============================================================================
// Optional stats table
// ============================================================================

var table statsTable = table.new(
     position.top_right,
     4,
     6,
     bgcolor = color.new(chart.bg_color, 15),
     border_color = color.new(chart.fg_color, 80),
     border_width = 1)

if barstate.islast
    table.clear(statsTable, 0, 0, 3, 5)

    if showTable
        table.set_position(statsTable, f_table_position(tablePosInput))

        tableSize = f_table_size(tableSizeInput)

        color headerColor = color.new(chart.fg_color, 25)
        color textColor = color.new(chart.fg_color, 10)

        int openUpGaps = 0
        int openDownGaps = 0

        if array.size(gapIsUp) > 0
            for i = 0 to array.size(gapIsUp) - 1
                openUpGaps += array.get(gapIsUp, i) ? 1 : 0
                openDownGaps += array.get(gapIsUp, i) ? 0 : 1

        string medianUp = f_med_string(fillBarsUp)
        string medianDown = f_med_string(fillBarsDown)

        int[] allFillBars = array.copy(fillBarsUp)

        if array.size(fillBarsDown) > 0
            for i = 0 to array.size(fillBarsDown) - 1
                array.push(allFillBars, array.get(fillBarsDown, i))

        string medianAll = f_med_string(allFillBars)

        float fillRateUp = totalUpGaps > 0 ? 100.0 * filledUpGaps / totalUpGaps : na
        float fillRateDown = totalDownGaps > 0 ? 100.0 * filledDownGaps / totalDownGaps : na
        float fillRateAll = totalUpGaps + totalDownGaps > 0 ? 100.0 * (filledUpGaps + filledDownGaps) / (totalUpGaps + totalDownGaps) : na
        float fillRateHighVolume = totalHighVolumeGaps > 0 ? 100.0 * filledHighVolumeGaps / totalHighVolumeGaps : na

        table.cell(statsTable, 0, 0, "Gap Map", text_color = headerColor, text_size = tableSize)
        table.cell(statsTable, 1, 0, "Up", text_color = headerColor, text_size = tableSize)
        table.cell(statsTable, 2, 0, "Down", text_color = headerColor, text_size = tableSize)
        table.cell(statsTable, 3, 0, "All", text_color = headerColor, text_size = tableSize)

        table.cell(statsTable, 0, 1, "True gaps", text_color = textColor, text_size = tableSize, text_halign = text.align_left)
        table.cell(statsTable, 1, 1, str.tostring(totalUpGaps), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 2, 1, str.tostring(totalDownGaps), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 3, 1, str.tostring(totalUpGaps + totalDownGaps), text_color = textColor, text_size = tableSize)

        table.cell(statsTable, 0, 2, "Filled so far", text_color = textColor, text_size = tableSize, text_halign = text.align_left)
        table.cell(statsTable, 1, 2, f_pct(fillRateUp), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 2, 2, f_pct(fillRateDown), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 3, 2, f_pct(fillRateAll), text_color = textColor, text_size = tableSize)

        table.cell(statsTable, 0, 3, "Median bars", text_color = textColor, text_size = tableSize, text_halign = text.align_left)
        table.cell(statsTable, 1, 3, medianUp, text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 2, 3, medianDown, text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 3, 3, medianAll, text_color = textColor, text_size = tableSize)

        table.cell(statsTable, 0, 4, "Open now", text_color = textColor, text_size = tableSize, text_halign = text.align_left)
        table.cell(statsTable, 1, 4, str.tostring(openUpGaps), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 2, 4, str.tostring(openDownGaps), text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 3, 4, str.tostring(openUpGaps + openDownGaps), text_color = textColor, text_size = tableSize)

        table.cell(statsTable, 0, 5, "HV filled", text_color = textColor, text_size = tableSize, text_halign = text.align_left)
        table.cell(statsTable, 1, 5, "", text_color = textColor, text_size = tableSize)
        table.cell(statsTable, 2, 5, "", text_color = textColor, text_size = tableSize)
        table.cell(
             statsTable,
             3,
             5,
             na(fillRateHighVolume) ? "-" : str.tostring(fillRateHighVolume, "0.0") + "% of " + str.tostring(totalHighVolumeGaps),
             text_color = textColor,
             text_size = tableSize)

// ============================================================================
// End of file
// ============================================================================
````

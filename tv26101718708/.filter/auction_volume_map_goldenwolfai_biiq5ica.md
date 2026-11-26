# Auction Volume Map [Golden_WolfAI]

- url: https://www.tradingview.com/script/bIiq5ICa-auction-volume-map-golden-wolfai/
- type: indicator
- pine_id: PUB;c13cd56c90e346739d346a5fbe87d4ad
- version: 1.0

## Description

Auction Volume Map — POC + Value Area + HVN/LVN + Pressure Delta

Auction Volume Map is a price-volume structure indicator designed to visualize how volume is distributed across price levels over a configurable rolling range of recent bars.

The indicator builds a normalized volume-density profile and automatically calculates:

POC — Point of Control

VAH — Value Area High

VAL — Value Area Low

HVN — High Volume Nodes

LVN — Low Volume Nodes

Pressure Delta

Delta %

nearest HVN and LVN to the current price

current price position relative to POC and Value Area

The indicator also includes an information panel and built-in TradingView alert conditions.

Volume Distribution Model

The profile is calculated over the latest number of bars selected in the Lookback Bars setting.

The highest and lowest prices of the analyzed range define the vertical boundaries of the profile.

This range is then divided into a configurable number of price rows.

Unlike a basic candle-direction volume profile, Auction Volume Map does not simply assign the full volume of a bullish candle to buyers or the volume of a bearish candle to sellers.

Instead, each candle's volume is distributed across the price rows actually traded by that candle.

For every candle, the algorithm evaluates:

candle high;

candle low;

candle open;

candle close;

candle volume;

the amount of each profile row intersected by the candle.

The volume distribution is normalized so that the candle's total assigned volume remains consistent with its original reported volume.

Price-Density Weighting

Volume is not distributed uniformly across the entire candle range.

The algorithm gives additional weight to price rows located closer to the candle's HLC3 reference price:

HLC3 = (High + Low + Close) / 3

Rows farther away from this reference receive progressively lower weighting.

This creates a smoother density model that attempts to represent where volume was more likely concentrated within each candle's traded range.

The weighting is normalized separately for every candle before its volume is added to the profile.

For nearly flat candles, volume is assigned directly to the corresponding price row.

Pressure Model

Auction Volume Map separates the calculated density into:

Positive Pressure

and

Negative Pressure

This separation is estimated using two components.

Close Location

The first component measures where the candle closed inside its own high-low range.

A close near the high contributes more positive pressure.

A close near the low contributes more negative pressure.

Body Impulse

The second component measures the displacement from the candle open to the candle close relative to the candle's total range.

A strong bullish body increases positive pressure.

A strong bearish body increases negative pressure.

The final pressure estimate combines these two components:

close location receives the larger weighting;

body displacement provides the secondary contribution.

The resulting value is constrained to a normalized range and used to divide each candle's distributed volume between positive and negative pressure.

Pressure Delta

The indicator calculates total positive and negative pressure volume across the complete profile.

Pressure Delta = Positive Pressure Volume − Negative Pressure Volume

It also calculates:

Delta % = Pressure Delta / Total Profile Volume × 100

A positive value indicates that the calculated positive-pressure component is larger within the analyzed range.

A negative value indicates that the calculated negative-pressure component is larger.

Pressure Delta is displayed in the Profile Summary panel with contextual color highlighting.

Important

Pressure Delta is a model-based estimate.

It is not Bid/Ask Delta, does not use aggressor-side transaction data, and should not be interpreted as true order-flow delta.

POC — Point of Control

Point of Control represents the price row containing the highest calculated volume density in the current profile.

The POC level is displayed as a horizontal line and can optionally include a price label.

Because the indicator uses a rolling lookback window, the POC can move when new candles are added and older candles leave the analyzed range.

POC therefore represents the current volume-density center of the selected rolling window rather than a permanently fixed historical level.

Value Area

The Value Area represents the section of the profile containing the selected percentage of total profile volume.

The default value can be configured by the user.

The calculation begins at the POC.

From there, the Value Area expands in a balanced manner around the POC by progressively including price rows below and above the current area.

Expansion continues until the accumulated volume reaches the configured target percentage.

The final boundaries are:

VAH — Value Area High

and

VAL — Value Area Low

Both levels can be displayed directly on the chart with customizable colors, widths, and labels.

HVN — High Volume Nodes

High Volume Nodes identify significant local concentrations of volume within the profile.

Before HVN detection, the raw volume-density profile is smoothed using neighboring rows.

This reduces sensitivity to isolated single-row fluctuations.

The algorithm then searches for local peaks in the smoothed profile.

To qualify as an HVN candidate, a row must:

form a local volume peak;

be above the average row volume;

not be the POC itself.

Each candidate receives a strength score based on its local prominence relative to neighboring rows.

The strongest candidates are selected while respecting the configured minimum spacing between nodes.

This helps reduce clusters of nearly identical HVN levels.

LVN — Low Volume Nodes

Low Volume Nodes identify locally thin areas of the profile.

LVN detection uses the same smoothed volume-density structure as HVN detection.

A valid LVN candidate must:

form a local volume trough;

be below the average row volume.

Its strength is measured by how far the row lies below its neighboring profile values.

The strongest LVN candidates are selected while maintaining the configured minimum spacing.

LVN levels are displayed as dashed horizontal lines.

Why the Profile Is Smoothed

Raw volume distributions can contain small irregularities caused by individual candles, row boundaries, or limited sample size.

Auction Volume Map applies a lightweight three-row smoothing process before detecting HVN and LVN structures.

The center row receives the largest weighting, while neighboring rows contribute smaller weights.

This smoothing is used only for node detection.

The visible volume profile itself continues to represent the underlying calculated density.

Nearest HVN / LVN

The indicator automatically identifies the currently selected HVN and LVN levels closest to the market price.

These values are shown in the Profile Summary panel.

They are also used by the built-in HVN and LVN touch alert conditions.

Profile Visualization

The profile is drawn directly on the right side of the current price chart.

Each price row contains two components:

Positive Pressure Volume

and

Negative Pressure Volume

Rows located inside the Value Area use stronger colors, while rows outside the Value Area use more transparent profile colors.

The profile width automatically scales relative to the highest-volume row.

A dedicated profile-width setting allows the user to control how much horizontal chart space the profile occupies.

Profile Summary

The indicator includes a compact information panel displaying the main statistics of the current profile.

The panel includes:

POC
Current Point of Control price.

VAH
Current Value Area High.

VAL
Current Value Area Low.

Price / POC
Shows whether the current price is ABOVE, BELOW, or AT the POC.

Value Area
Shows whether the current price is ABOVE, INSIDE, or BELOW the Value Area.

Nearest HVN
Closest selected High Volume Node.

Nearest LVN
Closest selected Low Volume Node.

Range
Total price range covered by the current profile.

Profile Volume
Total volume represented by the profile.

Pressure Delta
Difference between calculated positive and negative pressure volume.

Delta %
Pressure Delta expressed as a percentage of total profile volume.

The text size of the panel can be adjusted in the indicator settings.

Alerts

Auction Volume Map includes built-in TradingView alert conditions.

Available alerts include:

POC Cross

Triggered when price crosses the current Point of Control.

VAH Cross

Triggered when price crosses the current Value Area High.

VAL Cross

Triggered when price crosses the current Value Area Low.

Value Area Exit

Triggered when price moves from inside the current Value Area to outside it.

Value Area Return

Triggered when price returns inside the current Value Area.

HVN Touch

Triggered when price touches the nearest currently detected High Volume Node.

LVN Touch

Triggered when price touches the nearest currently detected Low Volume Node.

These alerts can be selected through TradingView's standard alert creation interface after the indicator has been added to a chart.

Main Settings

Lookback Bars

Controls how many recent candles are included in the profile calculation.

A larger value produces a broader market structure view.

A smaller value makes the profile more responsive to recent price activity.

Profile Rows

Controls the vertical resolution of the profile.

More rows provide greater price detail.

Fewer rows create a smoother and more generalized structure.

Value Area %

Defines the percentage of total profile volume included in the Value Area.

Profile Width

Controls the horizontal width of the displayed profile.

POC Settings

Control POC visibility, color, width, and label display.

VAH / VAL Settings

Control Value Area boundary lines, labels, colors, and line width.

HVN / LVN Settings

Control:

node visibility;

number of HVNs;

number of LVNs;

minimum spacing between nodes;

node colors;

node labels.

Profile Summary

Controls the information panel and its text size.

Practical Interpretation

Auction Volume Map is intended to provide structural information rather than direct trade signals.

POC highlights the strongest calculated concentration of volume within the current rolling range.

Value Area shows the region containing the selected percentage of total calculated profile volume.

HVNs highlight local areas of comparatively high volume concentration.

LVNs highlight local areas where volume density is relatively thin.

Pressure Delta provides additional context about the directional characteristics of the candles contributing to the profile.

These elements can be used together to study how price is interacting with areas of high and low participation.

Rolling Profile Behavior

Auction Volume Map uses the most recent selected number of bars.

It is therefore a rolling profile, not a manually anchored fixed-range profile.

As a new bar appears:

the newest bar enters the calculation;

the oldest bar eventually leaves the calculation;

the profile distribution may change;

POC may move;

VAH and VAL may move;

HVN and LVN levels may change;

Pressure Delta may change.

This behavior is intentional.

The indicator continuously represents the current structure of the selected rolling market window.

Limitations

Auction Volume Map does not use tick-level Bid/Ask transaction data.

It does not identify aggressive buyers or sellers directly.

Positive and negative pressure are estimated from candle structure and close location.

The internal distribution of each candle's volume across price is modeled mathematically because standard chart volume does not provide the exact traded volume at every price inside an individual candle.

Results therefore depend on:

available volume data;

selected timeframe;

lookback length;

number of profile rows;

market structure.

The indicator should be treated as an analytical visualization tool rather than a direct representation of exchange-level order flow.

Intended Use

Auction Volume Map is designed for traders who want a compact visualization of:

volume distribution across price;

Point of Control;

Value Area;

High Volume Nodes;

Low Volume Nodes;

directional pressure balance;

current price location within the profile;

automated alerts around important profile levels.

The indicator combines these elements into one chart-based view while keeping the calculation methodology transparent and configurable.

Pine Script® Version 6

© 2026 Golden_WolfAI. All rights reserved.

This Pine Script® code is proprietary and confidential.

Unauthorized copying, modification, redistribution, publication, or commercial use is prohibited.

## Source Code

````pine
//@version=6
// This Pine Script® code is proprietary and confidential.
// Unauthorized copying, modification, redistribution, publication, or commercial use is prohibited.
//
// © 2026 Golden_WolfAI. All rights reserved.

indicator('Auction Volume Map [Golden_WolfAI]', overlay = true, max_boxes_count = 250, max_lines_count = 100, max_labels_count = 100, max_bars_back = 501)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string G_PROFILE = 'Profile Model'
int lookbackBars = input.int(150, 'Lookback Bars', minval = 10, maxval = 500, group = G_PROFILE)
int rowCount = input.int(28, 'Price Rows', minval = 8, maxval = 100, group = G_PROFILE)
float valueAreaPct = input.float(70.0, 'Value Area %', minval = 10.0, maxval = 100.0, step = 1.0, group = G_PROFILE)
float profileWidthPct = input.float(34.0, 'Profile Width (% of lookback)', minval = 10.0, maxval = 80.0, step = 1.0, group = G_PROFILE)

string G_LEVELS = 'Key Levels'
color pocColor = input.color(color.red, 'POC', inline = 'poc', group = G_LEVELS)
int pocWidth = input.int(2, 'Width', minval = 1, maxval = 5, inline = 'poc', group = G_LEVELS)
bool showPocLabel = input.bool(true, 'POC label', group = G_LEVELS)
bool showValueAreaLines = input.bool(true, 'Show VAH / VAL', group = G_LEVELS)
bool showValueAreaLabels = input.bool(true, 'VAH / VAL labels', group = G_LEVELS)
color vahColor = input.color(color.aqua, 'VAH', inline = 'va', group = G_LEVELS)
color valColor = input.color(color.fuchsia, 'VAL', inline = 'va', group = G_LEVELS)
int vaWidth = input.int(2, 'Width', minval = 1, maxval = 5, inline = 'va', group = G_LEVELS)

string G_PROFILE_COLORS = 'Profile Colors'
color buyColor = input.color(color.new(color.teal, 70), 'Positive pressure', group = G_PROFILE_COLORS)
color sellColor = input.color(color.new(color.orange, 70), 'Negative pressure', group = G_PROFILE_COLORS)
color buyVaColor = input.color(color.new(color.teal, 30), 'VA positive pressure', group = G_PROFILE_COLORS)
color sellVaColor = input.color(color.new(color.orange, 30), 'VA negative pressure', group = G_PROFILE_COLORS)

string G_NODES = 'Volume Nodes'
bool showNodes = input.bool(true, 'Show HVN / LVN', group = G_NODES)
int hvnCount = input.int(3, 'HVN count', minval = 0, maxval = 8, group = G_NODES)
int lvnCount = input.int(3, 'LVN count', minval = 0, maxval = 8, group = G_NODES)
int nodeSpacing = input.int(2, 'Minimum spacing (rows)', minval = 0, maxval = 15, group = G_NODES)
color hvnColor = input.color(color.lime, 'HVN', inline = 'nodeColors', group = G_NODES)
color lvnColor = input.color(color.yellow, 'LVN', inline = 'nodeColors', group = G_NODES)
bool showNodeLabels = input.bool(false, 'Node labels', group = G_NODES)

string G_PANEL = 'Profile Summary'
bool showPanel = input.bool(true, 'Show summary', group = G_PANEL)
int panelTextSize = input.int(15, 'Text size', minval = 8, maxval = 30, group = G_PANEL)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_rowCenter(int row, float floorPrice, float rowHeight) =>
    floorPrice + (row + 0.5) * rowHeight

f_overlap(float aLow, float aHigh, float bLow, float bHigh) =>
    math.max(0.0, math.min(aHigh, bHigh) - math.max(aLow, bLow))

f_clamp01(float x) =>
    math.max(0.0, math.min(1.0, x))

f_farEnough(int candidate, array<int> chosen, int spacing) =>
    bool allowed = true
    if spacing > 0
        for item in chosen
            if math.abs(candidate - item) < spacing
                allowed := false
    allowed

f_chooseStrongest(array<float> scores, int wanted, int spacing) =>
    array<int> selected = array.new<int>()
    array<float> work = array.copy(scores)
    int attempts = math.min(wanted, array.size(work))
    if attempts > 0
        for _ = 0 to attempts - 1
            float bestScore = 0.0
            int bestRow = -1
            int n = array.size(work)
            if n > 0
                for row = 0 to n - 1
                    float score = array.get(work, row)
                    if score > bestScore and f_farEnough(row, selected, spacing)
                        bestScore := score
                        bestRow := row
            if bestRow >= 0
                array.push(selected, bestRow)
                array.set(work, bestRow, 0.0)
    selected

f_price(float value) =>
    na(value) ? 'N/A' : str.tostring(value, format.mintick)

f_volume(float value) =>
    na(value) ? 'N/A' : str.tostring(value, format.volume)

f_deleteLines(array<line> items) =>
    for obj in items
        line.delete(obj)
    array.clear(items)

f_deleteLabels(array<label> items) =>
    for obj in items
        label.delete(obj)
    array.clear(items)

//------------------------------------------------------------------------------
// Persistent drawings / alert state
//------------------------------------------------------------------------------
var array<box> positiveBoxes = array.new<box>()
var array<box> negativeBoxes = array.new<box>()
var array<line> hvnLines = array.new<line>()
var array<line> lvnLines = array.new<line>()
var array<label> hvnLabels = array.new<label>()
var array<label> lvnLabels = array.new<label>()

var line pocLine = na
var line vahLine = na
var line valLine = na
var label pocTag = na
var label vahTag = na
var label valTag = na

var table summary = table.new(position.top_right, 2, 12, border_width = 1)

var float livePoc = na
var float liveVah = na
var float liveVal = na
var float liveNearestHvn = na
var float liveNearestLvn = na

//------------------------------------------------------------------------------
// Profile engine
//------------------------------------------------------------------------------
if barstate.islast
    int barsUsed = math.min(lookbackBars, bar_index + 1)

    // 1) Build the active price range without relying on the original implementation's range pipeline.
    float rangeHigh = high
    float rangeLow = low
    if barsUsed > 1
        for offset = 1 to barsUsed - 1
            rangeHigh := math.max(rangeHigh, high[offset])
            rangeLow := math.min(rangeLow, low[offset])

    float span = math.max(rangeHigh - rangeLow, syminfo.mintick)
    float rowHeight = span / rowCount
    float rowPadding = rowHeight * 0.06

    array<float> totalDensity = array.new<float>(rowCount, 0.0)
    array<float> positiveDensity = array.new<float>(rowCount, 0.0)
    array<float> negativeDensity = array.new<float>(rowCount, 0.0)

    // 2) Independent distribution model.
    // Each bar's volume is normalized across the rows it actually trades through.
    // A bell-like proximity weight emphasizes prices near HLC3, while directional pressure
    // is estimated from both close location and candle body displacement.
    for offset = 0 to barsUsed - 1
        float barHigh = high[offset]
        float barLow = low[offset]
        float barOpen = open[offset]
        float barClose = close[offset]
        float barVol = nz(volume[offset], 0.0)
        float tradedRange = barHigh - barLow

        if barVol > 0
            float location = tradedRange > 0 ? (barClose - barLow) / tradedRange : 0.5
            float bodyImpulse = tradedRange > 0 ? (barClose - barOpen) / tradedRange : 0.0
            float pressureRaw = 0.65 * (location * 2.0 - 1.0) + 0.35 * bodyImpulse
            float pressure = math.max(-1.0, math.min(1.0, pressureRaw))
            float positiveShare = f_clamp01(0.5 + pressure * 0.5)
            float negativeShare = 1.0 - positiveShare

            if tradedRange <= syminfo.mintick * 0.1
                int flatRow = int(math.floor((barClose - rangeLow) / rowHeight))
                flatRow := math.max(0, math.min(rowCount - 1, flatRow))
                array.set(totalDensity, flatRow, array.get(totalDensity, flatRow) + barVol)
                array.set(positiveDensity, flatRow, array.get(positiveDensity, flatRow) + barVol * positiveShare)
                array.set(negativeDensity, flatRow, array.get(negativeDensity, flatRow) + barVol * negativeShare)
            else
                float anchor = (barHigh + barLow + barClose) / 3.0
                float scale = math.max(tradedRange * 0.35, rowHeight)
                float normalization = 0.0

                for row = 0 to rowCount - 1
                    float bucketLow = rangeLow + row * rowHeight
                    float bucketHigh = bucketLow + rowHeight
                    float occupied = f_overlap(bucketLow, bucketHigh, barLow, barHigh)
                    if occupied > 0
                        float center = f_rowCenter(row, rangeLow, rowHeight)
                        float z = (center - anchor) / scale
                        float proximity = 1.0 / (1.0 + z * z)
                        normalization += occupied * proximity

                if normalization > 0
                    for row = 0 to rowCount - 1
                        float bucketLow = rangeLow + row * rowHeight
                        float bucketHigh = bucketLow + rowHeight
                        float occupied = f_overlap(bucketLow, bucketHigh, barLow, barHigh)
                        if occupied > 0
                            float center = f_rowCenter(row, rangeLow, rowHeight)
                            float z = (center - anchor) / scale
                            float proximity = 1.0 / (1.0 + z * z)
                            float assigned = barVol * (occupied * proximity) / normalization
                            array.set(totalDensity, row, array.get(totalDensity, row) + assigned)
                            array.set(positiveDensity, row, array.get(positiveDensity, row) + assigned * positiveShare)
                            array.set(negativeDensity, row, array.get(negativeDensity, row) + assigned * negativeShare)

    float profileVolume = array.sum(totalDensity)
    float positiveVolume = array.sum(positiveDensity)
    float negativeVolume = array.sum(negativeDensity)
    float profileDelta = positiveVolume - negativeVolume
    float profileDeltaPct = profileVolume > 0 ? profileDelta / profileVolume * 100.0 : na
    bool validProfile = profileVolume > 0

    // 3) POC from the strongest density row.
    int pocRow = 0
    float maxRowVolume = array.get(totalDensity, 0)
    if rowCount > 1
        for row = 1 to rowCount - 1
            float rowVolume = array.get(totalDensity, row)
            if rowVolume > maxRowVolume
                maxRowVolume := rowVolume
                pocRow := row

    float pocPrice = validProfile ? f_rowCenter(pocRow, rangeLow, rowHeight) : na

    // 4) Value Area uses balanced expansion around POC.
    // This deliberately differs from one-side-at-a-time expansion: both neighboring sides
    // are absorbed per step until the requested volume share is reached.
    int vaBottomRow = pocRow
    int vaTopRow = pocRow
    float vaAccumulated = validProfile ? array.get(totalDensity, pocRow) : 0.0
    float vaTarget = profileVolume * valueAreaPct / 100.0

    while validProfile and vaAccumulated < vaTarget and (vaBottomRow > 0 or vaTopRow < rowCount - 1)
        if vaBottomRow > 0
            vaBottomRow -= 1
            vaAccumulated += array.get(totalDensity, vaBottomRow)
        if vaTopRow < rowCount - 1
            vaTopRow += 1
            vaAccumulated += array.get(totalDensity, vaTopRow)

    float vahPrice = validProfile ? rangeLow + (vaTopRow + 1) * rowHeight : na
    float valPrice = validProfile ? rangeLow + vaBottomRow * rowHeight : na

    // 5) Smooth density, then detect nodes using local prominence rather than raw extrema alone.
    array<float> smoothed = array.new<float>(rowCount, 0.0)
    for row = 0 to rowCount - 1
        float current = array.get(totalDensity, row)
        float left = array.get(totalDensity, math.max(0, row - 1))
        float right = array.get(totalDensity, math.min(rowCount - 1, row + 1))
        float filtered = row == 0 or row == rowCount - 1 ? (2.0 * current + left + right) / 4.0 : 0.25 * left + 0.50 * current + 0.25 * right
        array.set(smoothed, row, filtered)

    float meanRowVolume = profileVolume / rowCount
    array<float> hvnScores = array.new<float>(rowCount, 0.0)
    array<float> lvnScores = array.new<float>(rowCount, 0.0)

    if rowCount >= 3 and validProfile
        for row = 1 to rowCount - 2
            float left = array.get(smoothed, row - 1)
            float center = array.get(smoothed, row)
            float right = array.get(smoothed, row + 1)

            if row != pocRow and center > left and center >= right and center >= meanRowVolume
                float prominence = center - math.max(left, right)
                array.set(hvnScores, row, prominence)

            if center < left and center <= right and center <= meanRowVolume
                float prominence = math.min(left, right) - center
                array.set(lvnScores, row, prominence)

    array<int> hvnRows = f_chooseStrongest(hvnScores, hvnCount, nodeSpacing)
    array<int> lvnRows = f_chooseStrongest(lvnScores, lvnCount, nodeSpacing)

    float nearestHvn = na
    float nearestLvn = na
    float nearestHvnDistance = na
    float nearestLvnDistance = na

    for row in hvnRows
        float nodePrice = f_rowCenter(row, rangeLow, rowHeight)
        float d = math.abs(close - nodePrice)
        if na(nearestHvnDistance) or d < nearestHvnDistance
            nearestHvnDistance := d
            nearestHvn := nodePrice

    for row in lvnRows
        float nodePrice = f_rowCenter(row, rangeLow, rowHeight)
        float d = math.abs(close - nodePrice)
        if na(nearestLvnDistance) or d < nearestLvnDistance
            nearestLvnDistance := d
            nearestLvn := nodePrice

    //------------------------------------------------------------------------------
    // Draw profile with reusable box objects.
    //------------------------------------------------------------------------------
    if array.size(positiveBoxes) == 0
        for _ = 0 to rowCount - 1
            array.push(positiveBoxes, box.new(bar_index, close, bar_index, close, border_width = 0))
            array.push(negativeBoxes, box.new(bar_index, close, bar_index, close, border_width = 0))

    int profileWidthBars = math.max(4, int(math.round(barsUsed * profileWidthPct / 100.0)))
    int profileRight = bar_index

    for row = 0 to rowCount - 1
        float rowTotal = array.get(totalDensity, row)
        float rowPositive = array.get(positiveDensity, row)
        float rowNegative = array.get(negativeDensity, row)
        int totalWidth = maxRowVolume > 0 ? int(math.round(profileWidthBars * rowTotal / maxRowVolume)) : 0
        int positiveWidth = rowTotal > 0 ? int(math.round(totalWidth * rowPositive / rowTotal)) : 0
        int negativeWidth = math.max(0, totalWidth - positiveWidth)

        int leftEdge = profileRight - totalWidth
        int splitEdge = leftEdge + negativeWidth

        float topEdge = rangeLow + (row + 1) * rowHeight - rowPadding
        float bottomEdge = rangeLow + row * rowHeight + rowPadding
        bool inValueArea = row >= vaBottomRow and row <= vaTopRow

        box positiveBox = array.get(positiveBoxes, row)
        box negativeBox = array.get(negativeBoxes, row)

        box.set_lefttop(negativeBox, leftEdge, topEdge)
        box.set_rightbottom(negativeBox, splitEdge, bottomEdge)
        box.set_bgcolor(negativeBox, inValueArea ? sellVaColor : sellColor)

        box.set_lefttop(positiveBox, splitEdge, topEdge)
        box.set_rightbottom(positiveBox, profileRight, bottomEdge)
        box.set_bgcolor(positiveBox, inValueArea ? buyVaColor : buyColor)

    int levelStart = bar_index - barsUsed + 1

    // POC
    if validProfile
        if na(pocLine)
            pocLine := line.new(levelStart, pocPrice, bar_index, pocPrice, extend = extend.right, color = pocColor, width = pocWidth)
        else
            line.set_xy1(pocLine, levelStart, pocPrice)
            line.set_xy2(pocLine, bar_index, pocPrice)
            line.set_color(pocLine, pocColor)
            line.set_width(pocLine, pocWidth)
    else if not na(pocLine)
        line.set_color(pocLine, na)

    label.delete(pocTag)
    if validProfile and showPocLabel
        pocTag := label.new(bar_index + 3, pocPrice, 'POC  ' + f_price(pocPrice), style = label.style_label_left, color = color.new(pocColor, 0), textcolor = color.white)

    // VAH / VAL
    if validProfile and showValueAreaLines
        if na(vahLine)
            vahLine := line.new(levelStart, vahPrice, bar_index, vahPrice, extend = extend.right, color = vahColor, width = vaWidth)
        else
            line.set_xy1(vahLine, levelStart, vahPrice)
            line.set_xy2(vahLine, bar_index, vahPrice)
            line.set_color(vahLine, vahColor)
            line.set_width(vahLine, vaWidth)

        if na(valLine)
            valLine := line.new(levelStart, valPrice, bar_index, valPrice, extend = extend.right, color = valColor, width = vaWidth)
        else
            line.set_xy1(valLine, levelStart, valPrice)
            line.set_xy2(valLine, bar_index, valPrice)
            line.set_color(valLine, valColor)
            line.set_width(valLine, vaWidth)
    else
        if not na(vahLine)
            line.set_color(vahLine, na)
        if not na(valLine)
            line.set_color(valLine, na)

    label.delete(vahTag)
    label.delete(valTag)
    if validProfile and showValueAreaLines and showValueAreaLabels
        vahTag := label.new(bar_index + 3, vahPrice, 'VAH  ' + f_price(vahPrice), style = label.style_label_left, color = color.new(vahColor, 0), textcolor = color.white)
        valTag := label.new(bar_index + 3, valPrice, 'VAL  ' + f_price(valPrice), style = label.style_label_left, color = color.new(valColor, 0), textcolor = color.white)

    // Nodes
    f_deleteLines(hvnLines)
    f_deleteLines(lvnLines)
    f_deleteLabels(hvnLabels)
    f_deleteLabels(lvnLabels)

    if showNodes and validProfile
        for row in hvnRows
            float nodePrice = f_rowCenter(row, rangeLow, rowHeight)
            line nodeLine = line.new(levelStart, nodePrice, bar_index, nodePrice, extend = extend.right, color = hvnColor, width = 2)
            array.push(hvnLines, nodeLine)
            if showNodeLabels
                label nodeLabel = label.new(bar_index + 3, nodePrice, 'HVN  ' + f_price(nodePrice), style = label.style_label_left, color = hvnColor, textcolor = color.white)
                array.push(hvnLabels, nodeLabel)

        for row in lvnRows
            float nodePrice = f_rowCenter(row, rangeLow, rowHeight)
            line nodeLine = line.new(levelStart, nodePrice, bar_index, nodePrice, extend = extend.right, color = lvnColor, width = 2, style = line.style_dashed)
            array.push(lvnLines, nodeLine)
            if showNodeLabels
                label nodeLabel = label.new(bar_index + 3, nodePrice, 'LVN  ' + f_price(nodePrice), style = label.style_label_left, color = lvnColor, textcolor = color.black)
                array.push(lvnLabels, nodeLabel)

    //------------------------------------------------------------------------------
    // Summary panel (15 pt default ≈ 1.5x TradingView size.small).
    //------------------------------------------------------------------------------
    if showPanel
        string priceVsPoc = not validProfile ? 'N/A' : close > pocPrice ? 'ABOVE' : close < pocPrice ? 'BELOW' : 'AT'
        string vaState = not validProfile ? 'N/A' : close > vahPrice ? 'ABOVE' : close < valPrice ? 'BELOW' : 'INSIDE'

        color headerBg = color.new(color.gray, 65)
        color keyBg = color.new(color.gray, 88)
        color valueBg = color.new(color.black, 74)
        color deltaBg = not validProfile ? valueBg : profileDelta > 0 ? color.new(color.green, 70) : profileDelta < 0 ? color.new(color.red, 70) : valueBg

        table.cell(summary, 0, 0, 'AUCTION', text_color = color.white, bgcolor = headerBg, text_size = panelTextSize, text_formatting = text.format_bold)
        table.cell(summary, 1, 0, 'PROFILE', text_color = color.white, bgcolor = headerBg, text_size = panelTextSize, text_formatting = text.format_bold)

        table.cell(summary, 0, 1, 'POC', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 1, f_price(pocPrice), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 2, 'VAH', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 2, f_price(vahPrice), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 3, 'VAL', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 3, f_price(valPrice), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 4, 'Price / POC', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 4, priceVsPoc, text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 5, 'Value Area', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 5, vaState, text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 6, 'Nearest HVN', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 6, f_price(nearestHvn), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 7, 'Nearest LVN', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 7, f_price(nearestLvn), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 8, 'Range', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 8, f_price(rangeHigh - rangeLow), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 9, 'Profile Volume', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 9, f_volume(profileVolume), text_color = color.white, bgcolor = valueBg, text_size = panelTextSize)
        table.cell(summary, 0, 10, 'Pressure Delta', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 10, f_volume(profileDelta), text_color = color.white, bgcolor = deltaBg, text_size = panelTextSize)
        table.cell(summary, 0, 11, 'Delta %', text_color = color.white, bgcolor = keyBg, text_size = panelTextSize)
        table.cell(summary, 1, 11, na(profileDeltaPct) ? 'N/A' : str.tostring(profileDeltaPct, '#.##') + '%', text_color = color.white, bgcolor = deltaBg, text_size = panelTextSize)
    else
        table.clear(summary, 0, 0, 1, 11)

    // Publish current levels to alert logic.
    livePoc := pocPrice
    liveVah := vahPrice
    liveVal := valPrice
    liveNearestHvn := nearestHvn
    liveNearestLvn := nearestLvn

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
bool pocCross = not na(livePoc) and ((close > livePoc and close[1] <= livePoc) or (close < livePoc and close[1] >= livePoc))
bool vahCross = not na(liveVah) and ((close > liveVah and close[1] <= liveVah) or (close < liveVah and close[1] >= liveVah))
bool valCross = not na(liveVal) and ((close > liveVal and close[1] <= liveVal) or (close < liveVal and close[1] >= liveVal))

bool wasInsideVa = not na(liveVah) and not na(liveVal) and close[1] <= liveVah and close[1] >= liveVal
bool isInsideVa = not na(liveVah) and not na(liveVal) and close <= liveVah and close >= liveVal
bool valueAreaExit = wasInsideVa and not isInsideVa
bool valueAreaReturn = not wasInsideVa and isInsideVa

bool hvnTouch = not na(liveNearestHvn) and high >= liveNearestHvn and low <= liveNearestHvn and not (high[1] >= liveNearestHvn and low[1] <= liveNearestHvn)
bool lvnTouch = not na(liveNearestLvn) and high >= liveNearestLvn and low <= liveNearestLvn and not (high[1] >= liveNearestLvn and low[1] <= liveNearestLvn)

alertcondition(pocCross, 'Auction Volume Map: POC Cross', 'Price crossed the current POC.')
alertcondition(vahCross, 'Auction Volume Map: VAH Cross', 'Price crossed the current VAH.')
alertcondition(valCross, 'Auction Volume Map: VAL Cross', 'Price crossed the current VAL.')
alertcondition(valueAreaExit, 'Auction Volume Map: Value Area Exit', 'Price moved outside the current Value Area.')
alertcondition(valueAreaReturn, 'Auction Volume Map: Value Area Return', 'Price returned inside the current Value Area.')
alertcondition(hvnTouch, 'Auction Volume Map: HVN Touch', 'Price touched the nearest current HVN.')
alertcondition(lvnTouch, 'Auction Volume Map: LVN Touch', 'Price touched the nearest current LVN.')
````

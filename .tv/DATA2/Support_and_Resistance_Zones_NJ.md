<!-- tradingview-pine-id: PUB;854051fa700e460ea4d4e789257c103a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Support and Resistance Zones [NJ]

Source: https://www.tradingview.com/script/0NM6XH59-Support-and-Resistance-Zones-NJ/

## Description

✧ OVERVIEW ✧

Indicator identifies potential support and resistance zones using confirmed swing highs and lows.

Zones are formed when two swing points occur near the same price level within an ATR-based tolerance and the selected minimum and maximum distance between touches.

Confirmed zones extend forward to the current bar and can be used as reference areas for potential reversals, breakouts, and general market structure analysis.
[image]https://www.tradingview.com/x/wmUAYDOZ/[/image]

✧ SETTINGS ✧

Color Mode
Switches between colored support/resistance zones and a neutral white visualization.

Maximum Zones Shown
Controls the maximum number of support and resistance zones displayed on the chart.

Minimum Zone Distance
Controls the minimum distance required between existing and newly detected zones, measured in ATR.

Swing Strength
Controls swing sensitivity. Lower values detect smaller and more frequent swings, while higher values focus on stronger and less frequent swings.

Zone Tolerance
Controls how close two swing points must be to form the same support or resistance zone. Higher values allow a wider price difference.

Minimum Bars Between Touches
Sets the minimum number of bars required between the two swing points forming a zone.

Maximum Bars Between Touches
Sets the maximum number of bars allowed between the two swing points forming a zone.

✧ HOW IT WORKS ✧

Swing Detection
The indicator identifies confirmed swing highs and swing lows using pivot-based detection.

Zone Formation
A resistance zone is formed when two swing highs occur near the same price level.
A support zone is formed when two swing lows occur near the same price level.
The two swing points must fall within the selected ATR-based tolerance and within the selected minimum and maximum number of bars between touches.

Zone Placement
The center of each zone is calculated from the average price of the two matching swing points.
The width of the zone adapts to market volatility using ATR.

Zone Separation
Before a new zone is displayed, its distance from existing support and resistance zones is checked.
If the new zone is closer than the selected minimum zone distance, it is not displayed. This helps prevent multiple zones from clustering around essentially the same price level.

✧ VISUALIZATION ✧

Resistance zones are displayed in red and support zones in green when using Colored mode.

Neutral mode displays both types in white.

Once confirmed, each zone is drawn retrospectively from the first swing point used to form it and extends forward to the current bar.

Because swing highs and lows require future bars to be confirmed, the beginning of a zone can appear several bars before the indicator could have identified the completed structure in real time.

✧ USAGE ✧

The detected zones can provide market structure context for:

Support and resistance
Potential reversals
Breakout and retest analysis
Entry and exit areas
Stop-loss and take-profit placement
Confluence with other technical analysis

The zones represent areas rather than exact price levels and are best used alongside other forms of analysis rather than as standalone entry or exit signals.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Support and Resistance Zones [NJ]", "SRZ", overlay = true)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

t1 = "Maximum number of support and resistance zones shown on chart."
t2 = "Minimum distance between any support or resistance zones, measured in ATR."
t3 = "Higher values detect fewer, stronger swings. Lower values detect more frequent, smaller swings."
t4 = "How close two swings must be to form one zone. Higher values allow a wider match."
t5 = "Minimum bars required between the two touches forming a zone."
t6 = "Maximum bars allowed between the two touches forming a zone."

const string g1 = "✧ PLOTS ✧"
colorMode = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
maxBoxes    = input.int(4, "Maximum zones shown", minval = 1, group = g1, tooltip = t1)
minZoneDist = input.float(0.75, "Minimum zone distance", 0.1, step = 0.05, group = g1, tooltip = t2)

const string g2 = "✧ CALCULATION ✧"
pivotLen    = input.int(7, "Swing strength", 1, group = g2, tooltip = t3)
atrTolMulti = input.float(0.3, "Zone tolerance", 0.05, step = 0.05, group = g2, tooltip = t4)
minDist     = input.int(10, "Minimum bars between touches", 1, group = g2, tooltip = t5)
maxDist     = input.int(90, "Maximum bars between touches", 1, group = g2, tooltip = t6)

// ✧═════════════════✧
// ║      PIVOTS      ║
// ✧═════════════════✧

// Get pivots
pivotHigh = ta.pivothigh(pivotLen, pivotLen)
pivotLow  = ta.pivotlow(pivotLen, pivotLen)

// Actual candle where pivots occured
actualPivotBar = bar_index - pivotLen

// ✧════════════════════✧
// ║      TOLERANCE      ║
// ✧════════════════════✧

// Tolerance between support and resistance levels
atr = ta.atr(14)
pivotAtr = atr[pivotLen]

// ✧═════════════════✧
// ║      ARRAYS      ║
// ✧═════════════════✧

// Create arrays
var array<float> resistancePrice = array.new<float>()
var array<int>   resistanceBars  = array.new<int>()
var array<float> resistanceAtr   = array.new<float>()

var array<float> supportPrice = array.new<float>()
var array<int>   supportBars  = array.new<int>()
var array<float> supportAtr   = array.new<float>()

// Save values in arrays
if not na(pivotHigh)
    array.push(resistancePrice, pivotHigh)
    array.push(resistanceBars, actualPivotBar)
    array.push(resistanceAtr, pivotAtr)

if not na(pivotLow)
    array.push(supportPrice, pivotLow)
    array.push(supportBars, actualPivotBar)
    array.push(supportAtr, pivotAtr)

// Remove old array values
while array.size(resistanceBars) > 0 and actualPivotBar - array.get(resistanceBars, 0) > maxDist
    array.shift(resistancePrice)
    array.shift(resistanceBars)
    array.shift(resistanceAtr)

while array.size(supportBars) > 0 and actualPivotBar - array.get(supportBars, 0) > maxDist
    array.shift(supportPrice)
    array.shift(supportBars)
    array.shift(supportAtr)

// ✧══════════════════════════════════════✧
// ║      FIND SUPPORT AND RESISTANCE      ║
// ✧══════════════════════════════════════✧

// Check for resistance and save it if confirmed
bool resistanceConfirmed   = false
int resistanceMatchBar     = na
float resistanceMatchPrice = na
float resistanceMatchAtr   = na

if not na(pivotHigh) and not na(pivotAtr) and array.size(resistancePrice) > 0
    for i = 0 to array.size(resistancePrice) - 1
        oldPrice = array.get(resistancePrice, i)
        oldBar   = array.get(resistanceBars, i)
        oldAtr   = array.get(resistanceAtr, i)

        distance   = actualPivotBar - oldBar
        averageAtr = (pivotAtr + oldAtr) / 2
        tolerance  = averageAtr * atrTolMulti

        withinTolerance = math.abs(pivotHigh - oldPrice) <= tolerance
        withinDistance  = distance >= minDist and distance <= maxDist

        if withinTolerance and withinDistance
            resistanceConfirmed  := true
            resistanceMatchBar   := oldBar
            resistanceMatchPrice := (pivotHigh + oldPrice) / 2
            resistanceMatchAtr   := averageAtr
            break

// Check for support and save it if confirmed
bool supportConfirmed   = false
int supportMatchBar     = na
float supportMatchPrice = na
float supportMatchAtr   = na

if not na(pivotLow) and not na(pivotAtr) and array.size(supportPrice) > 0
    for i = 0 to array.size(supportPrice) - 1
        oldPrice = array.get(supportPrice, i)
        oldBar   = array.get(supportBars, i)
        oldAtr   = array.get(supportAtr, i)

        distance   = actualPivotBar - oldBar
        averageAtr = (pivotAtr + oldAtr) / 2
        tolerance  = averageAtr * atrTolMulti

        withinTolerance = math.abs(pivotLow - oldPrice) <= tolerance
        withinDistance  = distance >= minDist and distance <= maxDist

        if withinTolerance and withinDistance
            supportConfirmed  := true
            supportMatchBar   := oldBar
            supportMatchPrice := (pivotLow + oldPrice) / 2
            supportMatchAtr   := averageAtr
            break

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Box boundaries
resistanceTop    = resistanceMatchPrice + resistanceMatchAtr * atrTolMulti
resistanceBottom = resistanceMatchPrice - resistanceMatchAtr * atrTolMulti

supportTop    = supportMatchPrice + supportMatchAtr * atrTolMulti
supportBottom = supportMatchPrice - supportMatchAtr * atrTolMulti

// Store boxes
var array<box> srBoxes = array.new<box>()

// Box distance from each other
farEnough(float price, float atrValue) =>
    bool enough = true

    if array.size(srBoxes) > 0
        for i = 0 to array.size(srBoxes) - 1
            b = array.get(srBoxes, i)
            boxPrice = (box.get_top(b) + box.get_bottom(b)) / 2

            if math.abs(price - boxPrice) < atrValue * minZoneDist
                enough := false
                break

    enough

// Box colors
resCol = colorMode == "Neutral" ? color.white : color.rgb(120, 0, 32)
supCol = colorMode == "Neutral" ? color.white : color.rgb(0, 136, 100)

// Draw resistance box
if resistanceConfirmed and farEnough(resistanceMatchPrice, resistanceMatchAtr)
    newBox = box.new(
         left = resistanceMatchBar,
         top = resistanceTop,
         right = bar_index,
         bottom = resistanceBottom,
         xloc = xloc.bar_index,
         border_color = resCol,
         bgcolor = color.new(resCol, 90)
    )

    array.push(srBoxes, newBox)

    if array.size(srBoxes) > maxBoxes
        oldBox = array.shift(srBoxes)
        box.delete(oldBox)

// Draw support box
if supportConfirmed and farEnough(supportMatchPrice, supportMatchAtr)
    newBox = box.new(
         left = supportMatchBar,
         top = supportTop,
         right = bar_index,
         bottom = supportBottom,
         xloc = xloc.bar_index,
         border_color = supCol,
         bgcolor = color.new(supCol, 90)
    )

    array.push(srBoxes, newBox)

    if array.size(srBoxes) > maxBoxes
        oldBox = array.shift(srBoxes)
        box.delete(oldBox)

// Extend all zones to current bar
if array.size(srBoxes) > 0
    for i = 0 to array.size(srBoxes) - 1
        box.set_right(array.get(srBoxes, i), bar_index)
````

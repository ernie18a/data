# Auto Support/Resistance Zones

- url: https://www.tradingview.com/script/8QZiVtHo-Auto-Support-Resistance-Zones/
- type: indicator
- pine_id: PUB;1d655e0a2d4940aebe5176f09d93b03f
- version: 1.0

## Description

Auto Support Resistance Zones is a visual support and resistance mapping tool built from confirmed pivot highs and pivot lows.

The script automatically detects confirmed swing pivots, clusters nearby pivot prices into horizontal zones, and displays the most relevant zones around current price. Instead of drawing single-price support or resistance lines, it builds price areas because real market reactions often occur around ranges rather than exact levels.

What the script shows

- Horizontal support and resistance zones
- Zones built from confirmed pivot highs and pivot lows
- Touch count for each zone
- Zone role: S, R, or Inside
- Relative strength label: Valid, Good, or Strong
- Pivot source label: H, L, or H/L
- Zone price range
- A compact state label showing the nearest support and resistance context
- Optional alerts for zone entry, zone exit, support break, and resistance break

How it works

The script uses confirmed pivot highs and confirmed pivot lows. A pivot is only available after the selected Pivot strength bars have passed.

Nearby pivot prices are grouped into zones using an ATR-based clustering method. If multiple pivots occur close to the same price area, they are merged into one zone. The script then evaluates each zone using touch count, recency, and zone width.

The displayed zones can be selected using:

- Nearest to price
- Most touches
- Balanced strength

Balanced strength is designed to keep the chart cleaner by considering both the number of touches and the freshness of the zone.

Zone labels

Each zone label can show:

- S: price is above the zone, so the zone is currently acting as support
- R: price is below the zone, so the zone is currently acting as resistance
- Inside: price is currently trading inside the zone
- x count: number of confirmed pivot touches
- H: zone mainly built from pivot highs
- L: zone mainly built from pivot lows
- H/L: mixed pivot-high and pivot-low area
- Valid / Good / Strong: a relative descriptive strength label

The strength label is not a prediction. It is only a descriptive score based on the zone’s structure.

State label

The state label summarizes the current relationship between price and nearby zones. It can show whether price is inside a zone or between zones, and it displays the nearest resistance and support areas when available.

Main inputs

Pivot Detection:
- Pivot strength
- Lookback bars

Zone Building:
- Cluster width x ATR
- Zone padding x ATR
- Maximum zone height x ATR
- Minimum touches
- Minimum bars between touches
- Maximum zones shown
- Zone selection mode

Display:
- Zone starts from first touch or last touch
- Show zone labels
- Show S/R role
- Show touch counts
- Show strength
- Show pivot source H/L
- Show price ranges
- Show state label
- State label offset
- Right-side zone extension
- Label size

Style:
- Zone border width
- Zone fill transparency
- Zone border transparency
- Support color
- Resistance color
- Inside-zone color
- State label text color

Alerts

The script includes alert conditions for:

- Zone entered
- Zone exited
- Resistance broken
- Support broken

These alerts are descriptive chart events. They are not buy or sell signals.

Repainting and confirmation note

This script uses confirmed pivot highs and confirmed pivot lows. Because pivots require confirmation, a new pivot appears only after the selected Pivot strength bars have passed.

When new pivots are confirmed, zones can be rebuilt, merged, or reclassified as support, resistance, or inside-zone areas depending on current price. This is normal behavior for a confirmed-pivot support and resistance tool.

The script does not use future-looking signals to predict price movement. It displays zones derived from confirmed historical pivot structure.

Limitations

Support and resistance zones are visual reference areas, not guaranteed reaction levels.

A zone with more touches or a stronger label does not guarantee that price will reverse, hold, reject, or break from that zone.

The script is intended for chart analysis, education, and visual review of horizontal price structure. It is not a trading system, financial advice, or a standalone buy/sell tool.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Auto Support/Resistance Zones
// ============================================================================
// Automates horizontal support and resistance mapping.
//
// The script collects confirmed pivot highs and pivot lows, clusters nearby
// pivot prices into horizontal zones, and displays the strongest/nearest zones
// around current price.
//
// IMPORTANT MECHANICS
// - Pivots are confirmed with ta.pivothigh/ta.pivotlow.
// - A pivot appears only after Pivot strength bars have passed.
// - Pivots inside the selected ATR-based cluster width are merged into zones.
// - Touch counts, strength labels, and distance labels are descriptive only.
// - Zones are visual references, not buy/sell signals or forecasts.
// ============================================================================

indicator(
     title           = "Auto Support/Resistance Zones",
     shorttitle      = "AutoSR",
     overlay         = true,
     max_lines_count = 50,
     max_labels_count = 80,
     max_boxes_count = 80
)

// ============================================================================
// Inputs
// ============================================================================

int piv = input.int(
     defval  = 8,
     title   = "Pivot strength",
     minval  = 2,
     maxval  = 30,
     group   = "1) Pivot Detection",
     tooltip = "A pivot is confirmed this many bars after it happens. Higher values keep only larger, cleaner turning points."
)

int lookbackBars = input.int(
     defval  = 500,
     title   = "Lookback bars",
     minval  = 100,
     maxval  = 3000,
     step    = 50,
     group   = "1) Pivot Detection",
     tooltip = "Pivots older than this are dropped from the zone-building process."
)

float clusterWidthAtr = input.float(
     defval  = 0.75,
     title   = "Cluster width x ATR",
     minval  = 0.25,
     maxval  = 5.0,
     step    = 0.25,
     group   = "2) Zone Building",
     tooltip = "Pivots closer than this distance, measured in ATR(14), are merged into the same zone. Lower values create tighter zones."
)

float zonePaddingAtr = input.float(
     defval  = 0.10,
     title   = "Zone padding x ATR",
     minval  = 0.0,
     maxval  = 2.0,
     step    = 0.05,
     group   = "2) Zone Building",
     tooltip = "Adds a small visual buffer above and below each zone so thin zones remain visible."
)

float maxZoneHeightAtr = input.float(
     defval  = 4.5,
     title   = "Maximum zone height x ATR",
     minval  = 1.0,
     maxval  = 20.0,
     step    = 0.5,
     group   = "2) Zone Building",
     tooltip = "Zones wider than this ATR multiple are hidden to avoid overly broad, low-precision zones."
)

int minTouches = input.int(
     defval  = 2,
     title   = "Minimum touches",
     minval  = 1,
     maxval  = 10,
     group   = "2) Zone Building",
     tooltip = "A zone is shown only after this many confirmed pivot touches."
)

int minBarsBetweenTouches = input.int(
     defval  = 4,
     title   = "Minimum bars between touches",
     minval  = 0,
     maxval  = 100,
     group   = "2) Zone Building",
     tooltip = "Prevents very close pivots from inflating the touch count inside the same zone."
)

int maxZones = input.int(
     defval  = 5,
     title   = "Maximum zones shown",
     minval  = 1,
     maxval  = 10,
     group   = "2) Zone Building",
     tooltip = "Default is 5 to keep the chart clean."
)

string selectionMode = input.string(
     defval  = "Balanced strength",
     title   = "Zone selection",
     options = ["Nearest to price", "Most touches", "Balanced strength"],
     group   = "2) Zone Building",
     tooltip = "When more zones qualify than the maximum, keep either the nearest zones, the most touched zones, or zones with the strongest balance of touches and recency."
)

string zoneAnchorMode = input.string(
     defval  = "First touch",
     title   = "Zone starts from",
     options = ["First touch", "Last touch"],
     group   = "3) Display"
)

bool showZoneLabels = input.bool(
     defval = true,
     title  = "Show zone labels",
     group  = "3) Display"
)

bool showZoneRole = input.bool(
     defval = true,
     title  = "Show S/R role in labels",
     group  = "3) Display",
     active = showZoneLabels,
     tooltip = "Labels zones as S, R, or Inside according to current price position."
)

bool showTouchCounts = input.bool(
     defval = true,
     title  = "Show touch counts in labels",
     group  = "3) Display",
     active = showZoneLabels
)

bool showZoneStrength = input.bool(
     defval = true,
     title  = "Show strength in labels",
     group  = "3) Display",
     active = showZoneLabels,
     tooltip = "Shows Valid, Good, or Strong based on touch count, recency, and zone width."
)

bool showZoneSource = input.bool(
     defval = true,
     title  = "Show pivot source H/L",
     group  = "3) Display",
     active = showZoneLabels,
     tooltip = "Shows whether a zone came mainly from pivot highs, pivot lows, or both."
)

bool showZonePrices = input.bool(
     defval = true,
     title  = "Show prices in labels",
     group  = "3) Display",
     active = showZoneLabels
)

bool showStateLabel = input.bool(
     defval = true,
     title  = "Show state label",
     group  = "3) Display",
     tooltip = "Compact label with the nearest support and resistance zones and the distance to each."
)

int stateLabelOffsetBars = input.int(
     defval  = 24,
     title   = "State label offset bars",
     minval  = 0,
     maxval  = 250,
     group   = "3) Display",
     active  = showStateLabel,
     tooltip = "Moves the main state label farther to the right so it does not overlap zone labels."
)

int rightExtensionBars = input.int(
     defval  = 8,
     title   = "Extend zones right",
     minval  = 0,
     maxval  = 80,
     group   = "3) Display",
     tooltip = "Extends zone boxes to the right for easier reading. Visual extension only, not a forecast."
)

string labelSizeInput = input.string(
     defval  = "Small",
     title   = "Label size",
     options = ["Tiny", "Small", "Normal"],
     group   = "3) Display"
)

int zoneBorderWidth = input.int(
     defval = 1,
     title  = "Zone border width",
     minval = 1,
     maxval = 4,
     group  = "4) Style"
)

int zoneTransparency = input.int(
     defval = 84,
     title  = "Zone fill transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Style"
)

int zoneBorderTransparency = input.int(
     defval = 35,
     title  = "Zone border transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Style"
)

color supportColor = input.color(
     defval = color.rgb(72, 166, 126),
     title  = "Support zone color",
     group  = "5) Colors"
)

color resistanceColor = input.color(
     defval = color.rgb(201, 91, 101),
     title  = "Resistance zone color",
     group  = "5) Colors"
)

color insideColor = input.color(
     defval = color.rgb(212, 180, 131),
     title  = "Zone containing price",
     group  = "5) Colors"
)

color stateTextColor = input.color(
     defval = color.white,
     title  = "State label text color",
     group  = "5) Colors"
)

int hiddenTransparency = 100

// ============================================================================
// Helpers
// ============================================================================

float atr = ta.atr(14)

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Normal" ? size.normal :
     size.small

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_zone_strength(int touches, int lastTouchBar, float topValue, float botValue) =>
    float age = float(bar_index - lastTouchBar)
    float widthAtr = atr > 0.0 ? (topValue - botValue) / atr : 0.0

    float touchScore = math.min(float(touches) * 14.0, 70.0)
    float recencyScore = math.max(0.0, 30.0 - age / 10.0)
    float widthPenalty = math.max(0.0, widthAtr - 2.0) * 6.0

    f_clamp(touchScore + recencyScore - widthPenalty, 0.0, 100.0)

f_strength_text(float score) =>
    score >= 80.0 ? "Strong" :
     score >= 60.0 ? "Good" :
     "Valid"

f_zone_role(float displayTop, float displayBot) =>
    close > displayTop ? "S" :
     close < displayBot ? "R" :
     "Inside"

f_role_color(float displayTop, float displayBot) =>
    close > displayTop ? supportColor :
     close < displayBot ? resistanceColor :
     insideColor

f_pct_text(float levelValue) =>
    str.tostring((levelValue / close - 1.0) * 100.0, "0.0") + "%"

f_valid_zone(int j, float zoneTopValue, float zoneBotValue, int touches) =>
    float heightAtr = atr > 0.0 ? (zoneTopValue - zoneBotValue) / atr : 999.0
    touches >= minTouches and heightAtr <= maxZoneHeightAtr

// ============================================================================
// Pivot collection
// ============================================================================

float ph = ta.pivothigh(high, piv, piv)
float pl = ta.pivotlow(low, piv, piv)

var array<float> pivotPrices = array.new<float>()
var array<int>   pivotBars   = array.new<int>()
var array<int>   pivotTypes  = array.new<int>()  // 1 = pivot high, -1 = pivot low

if not na(ph)
    array.push(pivotPrices, ph)
    array.push(pivotBars, bar_index - piv)
    array.push(pivotTypes, 1)

if not na(pl)
    array.push(pivotPrices, pl)
    array.push(pivotBars, bar_index - piv)
    array.push(pivotTypes, -1)

while array.size(pivotBars) > 0 and array.get(pivotBars, 0) < bar_index - lookbackBars
    array.shift(pivotPrices)
    array.shift(pivotBars)
    array.shift(pivotTypes)

// ============================================================================
// Zone clustering
// ============================================================================

var array<float> zoneTop         = array.new<float>()
var array<float> zoneBot         = array.new<float>()
var array<int>   zoneTouches     = array.new<int>()
var array<int>   zoneHighTouches = array.new<int>()
var array<int>   zoneLowTouches  = array.new<int>()
var array<int>   zoneFirstBar    = array.new<int>()
var array<int>   zoneLastBar     = array.new<int>()

array.clear(zoneTop)
array.clear(zoneBot)
array.clear(zoneTouches)
array.clear(zoneHighTouches)
array.clear(zoneLowTouches)
array.clear(zoneFirstBar)
array.clear(zoneLastBar)

float clusterTol = clusterWidthAtr * atr

if not na(clusterTol) and array.size(pivotPrices) > 0
    for i = 0 to array.size(pivotPrices) - 1
        float p = array.get(pivotPrices, i)
        int b = array.get(pivotBars, i)
        int t = array.get(pivotTypes, i)

        int hit = -1

        if array.size(zoneTop) > 0
            for j = 0 to array.size(zoneTop) - 1
                float center = (array.get(zoneTop, j) + array.get(zoneBot, j)) / 2.0
                if hit < 0 and math.abs(p - center) <= clusterTol
                    hit := j

        if hit >= 0
            bool enoughSpacing = b - array.get(zoneLastBar, hit) >= minBarsBetweenTouches

            if enoughSpacing or minBarsBetweenTouches == 0
                array.set(zoneTop, hit, math.max(array.get(zoneTop, hit), p))
                array.set(zoneBot, hit, math.min(array.get(zoneBot, hit), p))
                array.set(zoneTouches, hit, array.get(zoneTouches, hit) + 1)
                array.set(zoneHighTouches, hit, array.get(zoneHighTouches, hit) + (t == 1 ? 1 : 0))
                array.set(zoneLowTouches, hit, array.get(zoneLowTouches, hit) + (t == -1 ? 1 : 0))
                array.set(zoneFirstBar, hit, math.min(array.get(zoneFirstBar, hit), b))
                array.set(zoneLastBar, hit, math.max(array.get(zoneLastBar, hit), b))
        else
            array.push(zoneTop, p)
            array.push(zoneBot, p)
            array.push(zoneTouches, 1)
            array.push(zoneHighTouches, t == 1 ? 1 : 0)
            array.push(zoneLowTouches, t == -1 ? 1 : 0)
            array.push(zoneFirstBar, b)
            array.push(zoneLastBar, b)

// ============================================================================
// Nearest zones
// ============================================================================

float nearestResTop = na
float nearestResBot = na
int   nearestResTouches = 0
float nearestSupTop = na
float nearestSupBot = na
int   nearestSupTouches = 0
bool  inAnyZone = false
int   inZoneTouches = 0

if array.size(zoneTop) > 0
    for j = 0 to array.size(zoneTop) - 1
        float zt = array.get(zoneTop, j) + zonePaddingAtr * atr
        float zb = array.get(zoneBot, j) - zonePaddingAtr * atr
        int touches = array.get(zoneTouches, j)

        if f_valid_zone(j, zt, zb, touches)
            if close > zt
                if na(nearestSupTop) or zt > nearestSupTop
                    nearestSupTop := zt
                    nearestSupBot := zb
                    nearestSupTouches := touches
            else if close < zb
                if na(nearestResBot) or zb < nearestResBot
                    nearestResTop := zt
                    nearestResBot := zb
                    nearestResTouches := touches
            else
                inAnyZone := true
                inZoneTouches := math.max(inZoneTouches, touches)

bool enteredZone = inAnyZone and not inAnyZone[1]
bool exitedZone  = not inAnyZone and inAnyZone[1]

bool brokeResistance =
     not na(nearestResTop[1]) and
     close > nearestResTop[1] and
     close[1] <= nearestResTop[1]

bool brokeSupport =
     not na(nearestSupBot[1]) and
     close < nearestSupBot[1] and
     close[1] >= nearestSupBot[1]

// ============================================================================
// Drawing objects
// ============================================================================

var array<box>   zoneBoxes  = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var label stateLabel = na

// ============================================================================
// Drawing
// ============================================================================

if barstate.islast

    while array.size(zoneBoxes) < maxZones
        array.push(zoneBoxes, box.new(bar_index, close, bar_index, close, border_color=color.new(color.white, 100), bgcolor=color.new(color.white, 100)))
        array.push(zoneLabels, label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.new(color.white, 100), size=labelSize))

    // Pick displayed zones.
    var array<int> pickedIdx = array.new<int>()
    array.clear(pickedIdx)

    int zCount = array.size(zoneTop)

    if zCount > 0
        array<bool> used = array.new_bool(zCount, false)

        for s = 0 to maxZones - 1
            int best = -1
            float bestMetric = na

            for j = 0 to zCount - 1
                float zt = array.get(zoneTop, j) + zonePaddingAtr * atr
                float zb = array.get(zoneBot, j) - zonePaddingAtr * atr
                int touches = array.get(zoneTouches, j)

                if not array.get(used, j) and f_valid_zone(j, zt, zb, touches)
                    float center = (zt + zb) / 2.0
                    float strength = f_zone_strength(touches, array.get(zoneLastBar, j), zt, zb)

                    float metric =
                         selectionMode == "Most touches" ?
                             -float(touches) :
                         selectionMode == "Balanced strength" ?
                             -strength :
                             math.abs(center - close)

                    if na(bestMetric) or metric < bestMetric
                        bestMetric := metric
                        best := j

            if best >= 0
                array.set(used, best, true)
                array.push(pickedIdx, best)

    int xEnd = bar_index + rightExtensionBars

    for s = 0 to maxZones - 1
        box bx = array.get(zoneBoxes, s)
        label lb = array.get(zoneLabels, s)

        if s < array.size(pickedIdx)
            int j = array.get(pickedIdx, s)

            float zt = array.get(zoneTop, j) + zonePaddingAtr * atr
            float zb = array.get(zoneBot, j) - zonePaddingAtr * atr

            int touches = array.get(zoneTouches, j)
            int highTouches = array.get(zoneHighTouches, j)
            int lowTouches = array.get(zoneLowTouches, j)

            int xStart =
                 zoneAnchorMode == "Last touch" ?
                     array.get(zoneLastBar, j) :
                     array.get(zoneFirstBar, j)

            color zoneCol = f_role_color(zt, zb)
            string role = f_zone_role(zt, zb)

            float strength = f_zone_strength(touches, array.get(zoneLastBar, j), zt, zb)
            string strengthText = f_strength_text(strength)

            box.set_lefttop(bx, xStart, zt)
            box.set_rightbottom(bx, xEnd, zb)
            box.set_bgcolor(bx, color.new(zoneCol, zoneTransparency))
            box.set_border_color(bx, color.new(zoneCol, zoneBorderTransparency))
            box.set_border_width(bx, zoneBorderWidth)

            string sourceText =
                 highTouches > lowTouches ? "H" :
                 lowTouches > highTouches ? "L" :
                 "H/L"

            string labelText =
                 not showZoneLabels ? "" :
                 (showZoneRole ? role + " " : "") +
                 (showZoneStrength ? strengthText + " " : "") +
                 (showTouchCounts ? "x" + str.tostring(touches) + " " : "") +
                 (showZoneSource ? "(" + sourceText + ")" : "") +
                 (showZonePrices ? "  " + str.tostring(zb, format.mintick) + " - " + str.tostring(zt, format.mintick) : "")

            label.set_xy(lb, xEnd + 1, (zt + zb) / 2.0)
            label.set_text(lb, labelText)
            label.set_textcolor(lb, showZoneLabels ? zoneCol : color.new(zoneCol, hiddenTransparency))
            label.set_color(lb, color.new(color.white, 100))
            label.set_size(lb, labelSize)
        else
            box.set_lefttop(bx, bar_index, close)
            box.set_rightbottom(bx, bar_index, close)
            box.set_bgcolor(bx, color.new(color.white, 100))
            box.set_border_color(bx, color.new(color.white, 100))
            label.set_text(lb, "")
            label.set_textcolor(lb, color.new(color.white, 100))

    // State label.
    string resLine =
         na(nearestResBot) ? "R: none in range" :
         "R " + str.tostring(nearestResBot, format.mintick) +
         " (" + (nearestResBot >= close ? "+" : "") + f_pct_text(nearestResBot) + ", x" + str.tostring(nearestResTouches) + ")"

    string supLine =
         na(nearestSupTop) ? "S: none in range" :
         "S " + str.tostring(nearestSupTop, format.mintick) +
         " (" + f_pct_text(nearestSupTop) + ", x" + str.tostring(nearestSupTouches) + ")"

    string stateHead =
         inAnyZone ? "Inside zone (x" + str.tostring(inZoneTouches) + ")" :
         "Between zones"

    color stateColor =
         inAnyZone ? insideColor :
         na(nearestResBot) ? supportColor :
         na(nearestSupTop) ? resistanceColor :
         nearestResBot - close <= close - nearestSupTop ? resistanceColor :
         supportColor

    string stateLabelText = stateHead + "\n" + resLine + "\n" + supLine

    if showStateLabel
        if na(stateLabel)
            stateLabel := label.new(
                 x = xEnd + 1 + stateLabelOffsetBars,
                 y = close,
                 text = stateLabelText,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = color.new(stateColor, 12),
                 textcolor = stateTextColor,
                 size = labelSize
            )
        else
            label.set_x(stateLabel, xEnd + 1 + stateLabelOffsetBars)
            label.set_y(stateLabel, close)
            label.set_text(stateLabel, stateLabelText)
            label.set_color(stateLabel, color.new(stateColor, 12))
            label.set_textcolor(stateLabel, stateTextColor)
            label.set_size(stateLabel, labelSize)
    else
        if not na(stateLabel)
            label.delete(stateLabel)
            stateLabel := na

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     enteredZone,
     title   = "Zone entered",
     message = "Auto SR Zones: price entered a support/resistance zone."
)

alertcondition(
     exitedZone,
     title   = "Zone exited",
     message = "Auto SR Zones: price exited a support/resistance zone."
)

alertcondition(
     brokeResistance,
     title   = "Resistance broken",
     message = "Auto SR Zones: close crossed above the nearest resistance zone."
)

alertcondition(
     brokeSupport,
     title   = "Support broken",
     message = "Auto SR Zones: close crossed below the nearest support zone."
)

// ============================================================================
// End of file
// ============================================================================
````

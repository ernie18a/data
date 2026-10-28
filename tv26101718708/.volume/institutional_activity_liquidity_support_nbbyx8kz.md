# Institutional Activity & Liquidity Support

- url: https://www.tradingview.com/script/nBbYX8KZ-Institutional-Activity-Liquidity-Support/
- type: indicator
- pine_id: PUB;55de0061d0274aa5a20af543c2c93d5f
- version: 1.0

## Description

| Color       | Meaning                                            |
| ----------- | -------------------------------------------------- |
| Green boxes | Monthly/Yearly liquidity sweep zones               |
| Blue boxes  | High-volume institutional buying / expansion zones |

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © LuxAlgo

//@version=6
indicator("Institutional Activity & Liquidity Support", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// --- Constants ---
string GROUP_DETECTION = "Detection Settings"
string GROUP_VISUALS   = "Visual Settings"
string GROUP_HTF       = "Major Liquidity Levels"

// --- Inputs ---
float volSpikeMult       = input.float(1.5, "Volume Spike Mult", minval = 1, step = 0.1, group = GROUP_DETECTION)
float expansionThreshold = input.float(1.2, "Expansion Mult", minval = 1, step = 0.1, group = GROUP_DETECTION)

bool useMonthlyLow = input.bool(true, "Detect Monthly Low Sweeps", group = GROUP_HTF)
bool useYearlyLow  = input.bool(true, "Detect Yearly Low Sweeps", group = GROUP_HTF)

color bullColorInput     = input.color(color.new(#089981, 0), "Label Color", group = GROUP_VISUALS)
color yearlyColorInput   = input.color(color.new(#089981, 40), "Yearly Sweep Zone", group = GROUP_VISUALS)
color monthlyColorInput  = input.color(color.new(#089981, 55), "Monthly Sweep Zone", group = GROUP_VISUALS)
color bigMoneyColorInput = input.color(color.new(#0062ff, 30), "Big Money Volume Zone", group = GROUP_VISUALS)

bool showLabelsInput  = input.bool(true, "Show Labels", group = GROUP_VISUALS)
bool showVolumeInfo   = input.bool(true, "Show Volume Data", group = GROUP_VISUALS)
bool extendZonesInput = input.bool(true, "Extend Sweep Zones Indefinitely", group = GROUP_VISUALS)

int blueBoxWidthInput  = input.int(50, "Blue Box Width (Bars)", minval = 1, group = GROUP_VISUALS)
int greenBoxWidthInput = input.int(50, "Green Box Width (Bars)", minval = 1, group = GROUP_VISUALS)

float minGreenNetPct = input.float(50.0, "Minimum Green Box Net %", minval = 0, step = 1, group = GROUP_VISUALS)

// --- Types ---
type ActivityLevel
    float price
    int barIndex
    string levelType
    bool isMitigated = false
    box zoneBox

// --- Helper Functions ---
f_format_volume(float vol) =>
    string res = ""
    float absVol = math.abs(vol)
    if absVol >= 1000000
        res := str.tostring(vol / 1000000, "#.##") + "M"
    else if absVol >= 1000
        res := str.tostring(vol / 1000, "#.#") + "K"
    else
        res := str.tostring(vol, "#")
    res

// --- Variables ---
var levelsArray = array.new<ActivityLevel>(0)

float avgVol  = ta.sma(volume, 20)
float avgBody = ta.sma(math.abs(close - open), 20)

// --- HTF Data ---
float prevMonthLow = request.security(syminfo.tickerid, "M", low[1])
float prevYearLow  = request.security(syminfo.tickerid, "12M", low[1])

// --- Detection Logic ---
bool isVolSpike = volume > avgVol * volSpikeMult and close > low + (high - low) * 0.3
bool isExpansion = close > open and math.abs(close - open) > avgBody * expansionThreshold and volume > avgVol * 1.3

bool isSweep = false
float sweptPrice = na
string sweepType = ""

if useYearlyLow and not na(prevYearLow) and low < prevYearLow and close > prevYearLow
    isSweep := true
    sweptPrice := prevYearLow
    sweepType := "Yearly Low Sweep"

if not isSweep and useMonthlyLow and not na(prevMonthLow) and low < prevMonthLow and close > prevMonthLow
    isSweep := true
    sweptPrice := prevMonthLow
    sweepType := "Monthly Low Sweep"

// --- Volume Calculation ---
float totalVol = volume
float buyRatio = (high - low) == 0 ? 0.5 : (close - low) / (high - low)
float sellRatio = 1.0 - buyRatio

float sharesBought = totalVol * buyRatio
float sharesSold   = totalVol * sellRatio
float netShares    = sharesBought - sharesSold
float netPct       = totalVol > 0 ? (netShares / totalVol) * 100 : 0

bool isGreenZone = isSweep
bool greenBoxAllowed = not isGreenZone or netPct > minGreenNetPct

bool confirmedActivity = (isVolSpike or isExpansion or isSweep) and greenBoxAllowed

// --- Visualization ---
if confirmedActivity
    float top = (isVolSpike or isExpansion) ? math.max(open, close) : sweptPrice
    float bottom = low

    string sigType = isVolSpike ? "Big Money Volume" : (isExpansion ? "Inst. Expansion" : "")

    color zoneColor = (isVolSpike or isExpansion) ? bigMoneyColorInput : (sweepType == "Yearly Low Sweep" ? yearlyColorInput : monthlyColorInput)

    bool isBlueZone = isVolSpike or isExpansion

    box actBox = box.new(
         left = bar_index,
         top = top,
         right = bar_index + (isBlueZone ? blueBoxWidthInput : greenBoxWidthInput),
         bottom = bottom,
         border_color = color.new(zoneColor, 0),
         bgcolor = zoneColor,
         extend = not isBlueZone and extendZonesInput ? extend.right : extend.none)

    if showLabelsInput
        string volData = showVolumeInfo ?
             "\n" + f_format_volume(totalVol) +
             "\n" + (netPct > 0 ? "+" : "") + str.tostring(netPct, "#.#") + "%" :
             ""

        label.new(
             bar_index,
             low,
             str.trim(sigType + volData),
             style = label.style_label_up,
             color = color.new(bullColorInput, 0),
             textcolor = color.white,
             size = size.small)

    levelsArray.push(ActivityLevel.new(top, bar_index, sweepType, false, actBox))

// --- Alerts ---
if isSweep and greenBoxAllowed
    alert("New Green Box Created: " + sweepType, alert.freq_once_per_bar)

bool priceEnteredGreenBox = false

// --- Mitigation & Retrace Detection ---
if levelsArray.size() > 0
    for i = levelsArray.size() - 1 to 0
        ActivityLevel level = levelsArray.get(i)

        if timeframe.isdaily and not level.isMitigated and (level.levelType == "Yearly Low Sweep" or level.levelType == "Monthly Low Sweep")
            if bar_index > level.barIndex and low <= level.price and high >= level.zoneBox.get_bottom()
                priceEnteredGreenBox := true

        if not level.isMitigated and close < level.zoneBox.get_bottom()
            level.isMitigated := true
            level.zoneBox.set_extend(extend.none)
            level.zoneBox.set_right(bar_index)
            level.zoneBox.set_bgcolor(color.new(chart.bg_color, 100))
            level.zoneBox.set_border_color(color.new(chart.fg_color, 80))

        if bar_index - level.barIndex > 5000
            levelsArray.remove(i)

if priceEnteredGreenBox
    alert("Price Retraced into Green Box on Daily Timeframe", alert.freq_once_per_bar)
````

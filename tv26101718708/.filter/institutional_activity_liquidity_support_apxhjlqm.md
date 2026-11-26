# Institutional Activity & Liquidity Support

- url: https://www.tradingview.com/script/apXhJlqm-Institutional-Activity-Liquidity-Support/
- type: indicator
- pine_id: PUB;94711c0d3e4749c9bcc88a1a64b903f5
- version: 1.0

## Description

only applicable for "Buy on Dips" and see levels which make best sense to add to your existing position or starting new position

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Institutional Activity & Liquidity Support", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// --- Constants ---
string GROUP_DETECTION = "Detection Settings"
string GROUP_VISUALS   = "Visual Settings"
string GROUP_HTF       = "Major Liquidity Levels"

// --- Inputs ---
float volSpikeMult       = input.float(1.5, "Volume Spike Mult", minval = 1, step = 0.1, tooltip = "Detects when volume is X times higher than average.", group = GROUP_DETECTION)
float expansionThreshold = input.float(1.2, "Expansion Mult", minval = 1, step = 0.1, tooltip = "How much larger the candle body must be than average.", group = GROUP_DETECTION)
bool  useMonthlyLow      = input.bool(true, "Detect Monthly Low Sweeps", group = GROUP_HTF)
bool  useYearlyLow       = input.bool(true, "Detect Yearly Low Sweeps", group = GROUP_HTF)

color bullColorInput     = input.color(color.new(#089981, 0), "Label Color", group = GROUP_VISUALS)
color yearlyColorInput   = input.color(color.new(#089981, 40), "Yearly Sweep Zone", group = GROUP_VISUALS)
color monthlyColorInput  = input.color(color.new(#089981, 55), "Monthly Sweep Zone", group = GROUP_VISUALS)
color bigMoneyColorInput = input.color(color.new(#0062ff, 30), "Big Money Volume Zone", group = GROUP_VISUALS)

bool  showLabelsInput    = input.bool(true, "Show Labels", group = GROUP_VISUALS)
bool  showVolumeInfo     = input.bool(true, "Show Volume Data", group = GROUP_VISUALS)
bool  extendZonesInput   = input.bool(true, "Extend Sweep Zones Indefinitely", tooltip = "Applies to Monthly and Yearly sweeps.", group = GROUP_VISUALS)
int   blueBoxWidthInput  = input.int(50, "Blue Box Width (Bars)", minval = 1, tooltip = "How many bars the blue 'Big Money' boxes should extend.", group = GROUP_VISUALS)

// --- Types ---
type ActivityLevel
    float price
    int   barIndex
    string levelType
    bool  isMitigated = false
    box   zoneBox

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
float avgVol = ta.sma(volume, 20)
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

bool confirmedActivity = isVolSpike or isExpansion or isSweep

// --- Granular Volume Calculation (Volume Delta Approximation) ---
// We calculate the ratio of volume that occurred in the 'Buying' vs 'Selling' portions of the candle
float totalVol = volume
float buyRatio = (high - low) == 0 ? 0.5 : (close - low) / (high - low)
float sellRatio = 1.0 - buyRatio

float sharesBought = totalVol * buyRatio
float sharesSold = totalVol * sellRatio
float netShares = sharesBought - sharesSold

// --- Visualization ---
if confirmedActivity
    float top = (isVolSpike or isExpansion) ? math.max(open, close) : sweptPrice
    float bottom = low
    string sigType = isVolSpike ? "Big Money Volume" : (isExpansion ? "Inst. Expansion" : sweepType)
    color zoneColor = (isVolSpike or isExpansion) ? bigMoneyColorInput : (sweepType == "Yearly Low Sweep" ? yearlyColorInput : monthlyColorInput)

    bool isBlueZone = (isVolSpike or isExpansion)
    
    box actBox = box.new(
         left         = bar_index, 
         top          = top, 
         right        = bar_index + (isBlueZone ? blueBoxWidthInput : 10), 
         bottom       = bottom, 
         border_color = color.new(zoneColor, 0), 
         bgcolor      = zoneColor,
         extend       = not isBlueZone and extendZonesInput ? extend.right : extend.none
         )


    if showLabelsInput
        float netPct = totalVol > 0 ? (netShares / totalVol) * 100 : 0
        string volData = showVolumeInfo ? 
             "\nTotal: " + f_format_volume(totalVol) + 
             "\nNet %: " + (netPct > 0 ? "+" : "") + str.tostring(netPct, "#.#") + "%" : ""


             
        label.new(bar_index, low, sigType + volData, 
             style=label.style_label_up, 
             color=color.new(bullColorInput, 0), 
             textcolor=color.white, 
             size=size.small)
    
    levelsArray.push(ActivityLevel.new(top, bar_index, sigType, false, actBox))

// --- Mitigation ---
if levelsArray.size() > 0
    for i = levelsArray.size() - 1 to 0
        ActivityLevel level = levelsArray.get(i)
        if not level.isMitigated and close < level.zoneBox.get_bottom()
            level.isMitigated := true
            level.zoneBox.set_extend(extend.none)
            level.zoneBox.set_right(bar_index)
            level.zoneBox.set_bgcolor(color.new(chart.bg_color, 100))
            level.zoneBox.set_border_color(color.new(chart.fg_color, 80))
        if bar_index - level.barIndex > 5000
            levelsArray.remove(i)
````

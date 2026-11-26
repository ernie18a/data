# Multi-Group Trend Boxes with POC Trend Line [XWiseTrade]

- url: https://www.tradingview.com/script/tZrx4zik-Multi-Group-Trend-Boxes-with-POC-Trend-Line-XWiseTrade/
- type: indicator
- pine_id: PUB;413558a55d2a47409a9c67c06d362a28
- version: 1.0

## Description

Advanced multi-timeframe trend structure visualization.

This indicator creates three independent groups of trend boxes, each with:
• Custom bar count and lower timeframe POC calculation
• Automatic up/down/sideways coloring
• Connecting POC trend line

Perfect for:
• Multi-timeframe confluence analysis
• Identifying trend strength across scales
• Clean structural price action mapping

Features:
• 3 fully customizable groups (short/medium/long term)
• Dynamic POC-based trend lines
• Transparent colored boxes
• High performance with object management

## Source Code

````pine
//@version=6
indicator("Multi-Group Trend Boxes with POC Trend Line [XWiseTrade]", overlay=true, max_boxes_count=500, max_lines_count=500, max_bars_back=5000)

// Global Inputs for all groups
bool showBoxes = input.bool(true, "Show Boxes for all groups")
bool showPocLine = input.bool(true, "Show POC Trend Line for all groups")
int max_history_offset = input.int(5000, "Max Historical Offset (for Pro account, max 5000)")

// Group 1 Inputs
var string GRP1 = "Group 1 Settings"
int grp1_n = input.int(3, "GRP1 Bars per Box", minval=1, maxval=500, group=GRP1)
int grp1_maxBoxes = input.int(128, "GRP1 Max Boxes to Draw", minval=1, maxval=2000, group=GRP1)
string grp1_low_tf = input.timeframe("1", "GRP1 Lower Timeframe for POC", options=["1s","5s","15s","30s","1","3","5","15","60","240","D","4H","1T","10T","100T"], group=GRP1)
color grp1_boxUpColor = input.color(color.green, "GRP1 Up Trend Box Color", group=GRP1)
color grp1_boxDownColor = input.color(color.red, "GRP1 Down Trend Box Color", group=GRP1)
color grp1_boxSideColor = input.color(color.yellow, "GRP1 Sideways Box Color", group=GRP1)
color grp1_pocLineColor = input.color(color.rgb(0, 0, 0, 50), "GRP1 POC Line Color", group=GRP1)

// Group 2 Inputs
var string GRP2 = "Group 2 Settings"
int grp2_n = input.int(12, "GRP2 Bars per Box", minval=1, maxval=500, group=GRP2)
int grp2_maxBoxes = input.int(32, "GRP2 Max Boxes to Draw", minval=1, maxval=1000, group=GRP2)
string grp2_low_tf = input.timeframe("1", "GRP2 Lower Timeframe for POC", options=["1s","5s","15s","30s","1","3","5","15","60","240","D","4H","1T","10T","100T"], group=GRP2)
color grp2_boxUpColor = input.color(color.green, "GRP2 Up Trend Box Color", group=GRP2)
color grp2_boxDownColor = input.color(color.red, "GRP2 Down Trend Box Color", group=GRP2)
color grp2_boxSideColor = input.color(color.yellow, "GRP2 Sideways Box Color", group=GRP2)
color grp2_pocLineColor = input.color(color.rgb(0, 0, 0, 75), "GRP2 POC Line Color", group=GRP2)

// Group 3 Inputs
var string GRP3 = "Group 3 Settings"
int grp3_n = input.int(48, "GRP3 Bars per Box", minval=1, maxval=500, group=GRP3)
int grp3_maxBoxes = input.int(8, "GRP3 Max Boxes to Draw", minval=1, maxval=1000, group=GRP3)
string grp3_low_tf = input.timeframe("1", "GRP3 Lower Timeframe for POC", options=["1s","5s","15s","30s","1","3","5","15","60","240","D","4H","1T","10T","100T"], group=GRP3)
color grp3_boxUpColor = input.color(color.green, "GRP3 Up Trend Box Color", group=GRP3)
color grp3_boxDownColor = input.color(color.red, "GRP3 Down Trend Box Color", group=GRP3)
color grp3_boxSideColor = input.color(color.yellow, "GRP3 Sideways Box Color", group=GRP3)
color grp3_pocLineColor = input.color(color.rgb(0, 0, 0), "GRP3 POC Line Color", group=GRP3)

// Timeframe Conversion Function
f_timeframeToPineString(tf) =>
    switch tf
        "1s" => "1S"
        "5s" => "5S"
        "15s" => "15S"
        "30s" => "30S"
        "1" => "1"
        "3" => "3"
        "5" => "5"
        "15" => "15"
        "60" => "60"
        "240" => "240"
        "4H" => "240"
        "D" => "D"
        "1T" => "1T"
        "10T" => "10T"
        "100T" => "100T"
        => na

// POC Calculation Function (modified for same timeframe)
getPOC(tfStr) =>
    if tfStr == timeframe.period
        close  // Fallback for same timeframe: use close as POC
    else
        [poc_lowCloses, poc_lowVols] = request.security_lower_tf(syminfo.tickerid, tfStr, [close, volume])
        if na(poc_lowCloses) or na(poc_lowVols)
            close  // Fallback if na
        else
            int sz = array.size(poc_lowCloses)
            if sz == 0
                close  // Fallback if empty
            else
                float totalVolPOC = 0.0
                float bestVal = na
                float bestRatio = 0.0
                for i = 0 to sz - 1
                    totalVolPOC += array.get(poc_lowVols, i)
                if totalVolPOC > 0
                    for i = 0 to sz - 1
                        float v = array.get(poc_lowVols, i)
                        float r = v / totalVolPOC
                        if r > bestRatio
                            bestRatio := r
                            bestVal := array.get(poc_lowCloses, i)
                na(bestVal) ? close : bestVal  // Fallback if no bestVal

// Group 1 POC
string grp1_low_tf_str = f_timeframeToPineString(grp1_low_tf)
float grp1_currPOC = getPOC(grp1_low_tf_str)

// Group 2 POC
string grp2_low_tf_str = f_timeframeToPineString(grp2_low_tf)
float grp2_currPOC = getPOC(grp2_low_tf_str)

// Group 3 POC
string grp3_low_tf_str = f_timeframeToPineString(grp3_low_tf)
float grp3_currPOC = getPOC(grp3_low_tf_str)

// Arrays for groups (separate for all)
var array<float> grp1_groupHighs = array.new<float>()
var array<float> grp1_groupLows = array.new<float>()
var array<float> grp1_groupPOCs = array.new<float>()
var array<int> grp1_groupMids = array.new<int>()
var array<box> grp1_boxArray = array.new<box>()
var array<line> grp1_lineArray = array.new<line>()

var array<float> grp2_groupHighs = array.new<float>()
var array<float> grp2_groupLows = array.new<float>()
var array<float> grp2_groupPOCs = array.new<float>()
var array<int> grp2_groupMids = array.new<int>()
var array<box> grp2_boxArray = array.new<box>()
var array<line> grp2_lineArray = array.new<line>()

var array<float> grp3_groupHighs = array.new<float>()
var array<float> grp3_groupLows = array.new<float>()
var array<float> grp3_groupPOCs = array.new<float>()
var array<int> grp3_groupMids = array.new<int>()
var array<box> grp3_boxArray = array.new<box>()
var array<line> grp3_lineArray = array.new<line>()

// Function to process a group (to avoid code duplication)
f_processGroup(int n, int maxBoxes, float currPOC, color boxUpColor, color boxDownColor, color boxSideColor, color pocLineColor, bool showBoxes, bool showPocLine, array<float> groupHighs, array<float> groupLows, array<float> groupPOCs, array<int> groupMids, array<box> boxArray, array<line> lineArray) =>
    array.clear(groupHighs)
    array.clear(groupLows)
    array.clear(groupPOCs)
    array.clear(groupMids)
    if array.size(boxArray) > 0
        for b = 0 to array.size(boxArray) - 1
            box.delete(array.get(boxArray, b))
    array.clear(boxArray)
    if array.size(lineArray) > 0
        for l = 0 to array.size(lineArray) - 1
            line.delete(array.get(lineArray, l))
    array.clear(lineArray)
    
    int max_possible = math.floor((bar_index + 1) / n)
    int max_by_history = math.floor(max_history_offset / n) + 1
    int maxPossibleGroups = math.min(maxBoxes, max_possible, max_by_history)
    
    int drawn = 0
    for j = 0 to maxPossibleGroups - 1
        int i = maxPossibleGroups - 1 - j
        int rightBar = bar_index - i * n
        int leftBar = math.max(0, rightBar - n + 1)
        int effN = rightBar - leftBar + 1
        
        int start_offset = bar_index - rightBar
        int end_offset = bar_index - leftBar
        if end_offset > max_history_offset
            continue
        
        float gHigh = -1e100
        float gLow = 1e100
        int highLowCount = 0
        bool validGroup = true
        for offset = start_offset to end_offset
            if offset < 0 or offset > bar_index or offset > max_history_offset
                validGroup := false
                break
            float h = high[offset]
            float l = low[offset]
            if not na(h) and not na(l)
                gHigh := math.max(gHigh, h)
                gLow := math.min(gLow, l)
                highLowCount += 1
        
        float sumPOC = 0.0
        int validCount = 0
        for offset = start_offset to end_offset
            if offset < 0 or offset > bar_index or offset > max_history_offset
                validGroup := false
                break
            float pocVal = currPOC[offset]
            if not na(pocVal)
                sumPOC += pocVal
                validCount += 1
        float gPOC = validCount > 0 ? sumPOC / validCount : na
        
        if na(gPOC)
            if highLowCount > 0
                gPOC := math.avg(gHigh, gLow)  // Fallback to mid if POC na
            else
                continue
        
        if not validGroup or highLowCount == 0 or na(gHigh) or na(gLow) or na(gPOC) or gHigh == -1e100 or gLow == 1e100
            continue
        
        array.push(groupHighs, gHigh)
        array.push(groupLows, gLow)
        array.push(groupPOCs, gPOC)
        int midBar = math.round((leftBar + rightBar) / 2.0)
        array.push(groupMids, midBar)
        
        color boxColor = boxSideColor
        int size = array.size(groupHighs)
        if size > 1
            float prevH = array.get(groupHighs, size - 2)
            float prevL = array.get(groupLows, size - 2)
            if gHigh > prevH and gLow > prevL
                boxColor := boxUpColor
            else if gHigh < prevH and gLow < prevL
                boxColor := boxDownColor
        
        if showBoxes
            box b = box.new(leftBar, gHigh, rightBar, gLow, border_color=boxColor, bgcolor=color.new(boxColor, 90), border_width=2, extend=extend.none)
            array.push(boxArray, b)
        
        drawn += 1
    
    if showPocLine and array.size(groupPOCs) >= 2
        int maxLines = math.min(array.size(groupPOCs) - 1, 100)
        for j = 1 to maxLines
            int x1 = array.get(groupMids, j - 1)
            float y1 = array.get(groupPOCs, j - 1)
            int x2 = array.get(groupMids, j)
            float y2 = array.get(groupPOCs, j)
            if not na(y1) and not na(y2)
                line l = line.new(x1, y1, x2, y2, color=pocLineColor, width=2)
                array.push(lineArray, l)
    
    array<int> ret = array.new<int>()
    array.push(ret, drawn)
    array.push(ret, maxPossibleGroups)
    ret

// Update only on the last bar
if barstate.islast
    array<int> result1 = f_processGroup(grp1_n, grp1_maxBoxes, grp1_currPOC, grp1_boxUpColor, grp1_boxDownColor, grp1_boxSideColor, grp1_pocLineColor, showBoxes, showPocLine, grp1_groupHighs, grp1_groupLows, grp1_groupPOCs, grp1_groupMids, grp1_boxArray, grp1_lineArray)
    int grp1_drawnGroups = array.get(result1, 0)
    int grp1_maxPossibleGroups = array.get(result1, 1)
    
    array<int> result2 = f_processGroup(grp2_n, grp2_maxBoxes, grp2_currPOC, grp2_boxUpColor, grp2_boxDownColor, grp2_boxSideColor, grp2_pocLineColor, showBoxes, showPocLine, grp2_groupHighs, grp2_groupLows, grp2_groupPOCs, grp2_groupMids, grp2_boxArray, grp2_lineArray)
    int grp2_drawnGroups = array.get(result2, 0)
    int grp2_maxPossibleGroups = array.get(result2, 1)
    
    array<int> result3 = f_processGroup(grp3_n, grp3_maxBoxes, grp3_currPOC, grp3_boxUpColor, grp3_boxDownColor, grp3_boxSideColor, grp3_pocLineColor, showBoxes, showPocLine, grp3_groupHighs, grp3_groupLows, grp3_groupPOCs, grp3_groupMids, grp3_boxArray, grp3_lineArray)
    int grp3_drawnGroups = array.get(result3, 0)
    int grp3_maxPossibleGroups = array.get(result3, 1)
````

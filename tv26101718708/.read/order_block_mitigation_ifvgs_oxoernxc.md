# Order Block Mitigation + IFVGs

- url: https://www.tradingview.com/script/OxoErNXc-Order-Block-Mitigation-IFVGs/
- type: indicator
- pine_id: PUB;2fc42e15d1b94eb7b5c9d32dbf1b374f
- version: 1.0

## Description

This script identifies Ifvgs and high probability order blocks that price should return to. Easy for beginners

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Order Block Mitigation + IFVGs", "LuxAlgo - OB Mitigation + IFVGs", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)
//---------------------------------------------------------------------------------------------------------------------}
// Constants
//---------------------------------------------------------------------------------------------------------------------{
color BULL_COLOR      = #089981
color BEAR_COLOR      = #f23645
color HPZ_BULL        = #1de9b6
color HPZ_BEAR        = #ff5252
color NEUTRAL_COLOR   = color.gray

// Table Constants
color DATA                  = #DBDBDB
color HEADERS                 = #808080
color BACKGROUND              = #161616
color BORDERS                 = #2E2E2E

string TOP_RIGHT               = 'Top Right'
string BOTTOM_RIGHT            = 'Bottom Right'
string BOTTOM_LEFT             = 'Bottom Left'

string TINY                    = 'Tiny'
string SMALL                   = 'Small'
string NORMAL                  = 'Normal'
string LARGE                   = 'Large'
string HUGE                    = 'Huge'

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
string DASHBOARD_GROUP         = 'Dashboard'
string MS_GROUP                = "Market Structure"
string VISUALS_GROUP           = "Visuals"
string OB_GROUP                = "Order Blocks"
string IFVG_GROUP              = "Inversion FVGs"
string SESSIONS_GROUP          = "Sessions"

// Dashboard Inputs
bool showStatsInput          = input.bool(   true,       'Show Advanced Analytics', group = DASHBOARD_GROUP)
string dashboardPositionInput  = input.string( TOP_RIGHT,  'Position',                group = DASHBOARD_GROUP, options = [TOP_RIGHT,BOTTOM_RIGHT,BOTTOM_LEFT])
string dashboardSizeInput      = input.string( SMALL,      'Size',                    group = DASHBOARD_GROUP, options = [TINY,SMALL,NORMAL,LARGE,HUGE])

// Market Structure
int pivotLenInput           = input.int(7, "Pivot Lookback", minval = 1, group = MS_GROUP)
float msbZScoreInput          = input.float(0.5, "MSB Momentum Z-Score", minval = 0.1, step = 0.1, group = MS_GROUP)

// Visuals
string modeInput               = input.string("Historical", "Display Mode", options = ["Historical", "Present"], group = VISUALS_GROUP)

// Order Blocks
int obCountInput            = input.int(10, "Max Active OBs", minval = 1, maxval = 100, group = OB_GROUP)
bool extendBrokenInput       = input.bool(false, "Extend Broken OBs", group = OB_GROUP)
bool hideOverlapsInput       = input.bool(false, "Hide Overlapping OBs", group = OB_GROUP)

// Inversion Fair Value Gaps
bool showIfvgInput            = input.bool(true, "Show IFVGs", group = IFVG_GROUP)
int maxIfvgInput              = input.int(1, "Max Active IFVGs", minval = 1, maxval = 100, group = IFVG_GROUP, tooltip = "Maximum number of active IFVGs to display.")
int ifvgVolThresholdInput     = input.int(50, "Volume Threshold (Percentile)", minval = 0, maxval = 100, group = IFVG_GROUP, tooltip = "Minimum volume percentile for the original FVG.")
color ifvgBullColorInput      = input.color(color.new(BULL_COLOR, 85), "Bullish IFVG (Support)", group = IFVG_GROUP, tooltip = "Color for Bearish FVGs that were inverted by a close above.")
color ifvgBearColorInput      = input.color(color.new(BEAR_COLOR, 85), "Bearish IFVG (Resistance)", group = IFVG_GROUP, tooltip = "Color for Bullish FVGs that were inverted by a close below.")

// Sessions
bool showSessionsInput       = input.bool(true, "Show Session Ranges", group = SESSIONS_GROUP)

bool showLondonInput         = input.bool(false, "London Session", group = SESSIONS_GROUP)
string londonSessInput         = input.session("0800-1700:1234567", "London Time", group = SESSIONS_GROUP)
color londonColInput          = input.color(#3b82f6, "London Color", group = SESSIONS_GROUP, inline = "London")

bool showNYInput             = input.bool(false, "New York Session", group = SESSIONS_GROUP)
string nySessInput             = input.session("1300-2200:1234567", "New York Time", group = SESSIONS_GROUP)
color nyColInput              = input.color(#f97316, "New York Color", group = SESSIONS_GROUP, inline = "NY")

bool showTokyoInput          = input.bool(false, "Tokyo Session", group = SESSIONS_GROUP)
string tokyoSessInput          = input.session("0000-0900:1234567", "Tokyo Time", group = SESSIONS_GROUP)
color tokyoColInput           = input.color(#f43f5e, "Tokyo Color", group = SESSIONS_GROUP, inline = "Tokyo")

bool showSydneyInput         = input.bool(false, "Sydney Session", group = SESSIONS_GROUP)
string sydneySessInput         = input.session("2100-0600:1234567", "Sydney Time", group = SESSIONS_GROUP)
color sydneyColInput          = input.color(#eab308, "Sydney Color", group = SESSIONS_GROUP, inline = "Sydney")

//---------------------------------------------------------------------------------------------------------------------}
// Types & Collections
//---------------------------------------------------------------------------------------------------------------------{
type OrderBlock
    box        boxId
    label      labelId
    line       pocLineId
    float      qualityScore
    float      top
    float      bottom
    bool       isBull
    bool       isHPZ = false
    bool       mitigated = false
    int        mitigationBar = 0

type InversionFVG
    box        boxId = na
    label      labelId = na
    float      top
    float      bottom
    bool       isBullGap // Original Gap Bias
    bool       inverted = false
    bool       mitigated = false
    int        startBar

var obArray   = array.new<OrderBlock>()
var ifvgArray = array.new<InversionFVG>()

//---------------------------------------------------------------------------------------------------------------------}
// User-Defined Functions
//---------------------------------------------------------------------------------------------------------------------{
var parsedDashboardPosition = switch dashboardPositionInput
    TOP_RIGHT       => position.top_right
    BOTTOM_RIGHT    => position.bottom_right
    BOTTOM_LEFT     => position.bottom_left

var parsedDashboardSize     = switch dashboardSizeInput
    TINY            => size.tiny
    SMALL           => size.small
    NORMAL          => size.normal
    LARGE           => size.large
    HUGE            => size.huge

cell(table t_able, int column, int row, string data, color color = #FFFFFF, string align = text.align_right, color background = na, float height = 0) => 
    t_able.cell(column,row,data,text_color = color, text_size = parsedDashboardSize, text_halign = align, bgcolor = background, height = height)

divider(table t_able, int row, int lastColumn) =>    
    string rowDivider = '━━━━━━━━━━━━━━'
    t_able.merge_cells(0,row,lastColumn,row)
    cell(t_able,0,row,rowDivider,align = text.align_center, height = 0.5, color = BORDERS)

drawSession(bool show, string sessStr, color col, string name) =>
    var box   sBox   = na
    var label sLabel = na
    var float sHigh  = na
    var float sLow   = na

    bool inSession = not na(time(timeframe.period, sessStr))
    bool isStart   = inSession and not inSession[1]

    if show and inSession
        if isStart
            sHigh  := high
            sLow   := low
            sBox   := box.new(bar_index, sHigh, bar_index, sLow, border_color = col, border_style = line.style_dotted, bgcolor = color.new(col, 92))
            sLabel := label.new(bar_index, sHigh, name, style = label.style_none, textcolor = col, size = size.small, textalign = text.align_center)
        else
            sHigh := math.max(sHigh, high)
            sLow  := math.min(sLow, low)
            sBox.set_top(sHigh)
            sBox.set_bottom(sLow)
            sBox.set_right(bar_index)
            sLabel.set_xy(math.round(math.avg(sBox.get_left(), bar_index)), sHigh)
    float(na)

//---------------------------------------------------------------------------------------------------------------------}
// Core Calculations
//---------------------------------------------------------------------------------------------------------------------{
float priceChange = ta.change(close)
float avgChange   = ta.sma(priceChange, 50)
float stdChange   = ta.stdev(priceChange, 50)
float momentumZ   = (priceChange - avgChange) / stdChange
float volPercent  = ta.percentrank(volume, 100)

// Pivot Detection
float ph = ta.pivothigh(high, pivotLenInput, pivotLenInput)
float pl = ta.pivotlow(low, pivotLenInput, pivotLenInput)

var float lastPh = na
var float lastPl = na
var int lastPhIdx = na
var int lastPlIdx = na

if not na(ph)
    lastPh := ph
    lastPhIdx := bar_index - pivotLenInput
if not na(pl)
    lastPl := pl
    lastPlIdx := bar_index - pivotLenInput

// Session Range Logic
if showSessionsInput
    drawSession(showLondonInput, londonSessInput, londonColInput, "London")
    drawSession(showNYInput,     nySessInput,     nyColInput,     "New York")
    drawSession(showTokyoInput,  tokyoSessInput,  tokyoColInput,  "Tokyo")
    drawSession(showSydneyInput, sydneySessInput, sydneyColInput, "Sydney")

// Market Structure Breaks (MSB)
bool isMSBBull = close > lastPh and close[1] <= lastPh and momentumZ > msbZScoreInput
bool isMSBBear = close < lastPl and close[1] >= lastPl and momentumZ < -msbZScoreInput

if isMSBBull
    int mid = math.round(math.avg(lastPhIdx, bar_index))
    line.new(lastPhIdx, lastPh, bar_index, lastPh, color = color.new(BULL_COLOR, 0), width = 1)
    label.new(mid, lastPh, "MSB", color = color.new(BULL_COLOR, 100), textcolor = BULL_COLOR, style = label.style_label_down, size = size.small)

if isMSBBear
    int mid = math.round(math.avg(lastPlIdx, bar_index))
    line.new(lastPlIdx, lastPl, bar_index, lastPl, color = color.new(BEAR_COLOR, 0), width = 1)
    label.new(mid, lastPl, "MSB", color = color.new(BEAR_COLOR, 100), textcolor = BEAR_COLOR, style = label.style_label_up, size = size.small)

// Institutional Order Block Logic
if isMSBBull or isMSBBear
    int obIdx = 0
    for i = 1 to 10
        if (isMSBBull and close[i] < open[i]) or (isMSBBear and close[i] > open[i])
            obIdx := i
            break

    float obTop    = high[obIdx]
    float obBottom = low[obIdx]
    float obPOC    = math.avg(obTop, obBottom)

    // Quality Score (0-100)
    float score = math.min(100, (math.abs(momentumZ) * 20) + (volPercent * 0.5))
    bool isHPZ = score > 80 

    color baseColor = isMSBBull ? BULL_COLOR : BEAR_COLOR
    color hpzColor  = isMSBBull ? HPZ_BULL   : HPZ_BEAR

    box   obBox = na
    label obLabel = na
    line  obPoc = na

    // Overlap Logic
    bool overlapping = false
    if hideOverlapsInput and obArray.size() > 0
        for i = 0 to obArray.size() - 1
            OrderBlock o = obArray.get(i)
            if not o.mitigated and ((obTop <= o.top and obTop >= o.bottom) or (obBottom <= o.top and obBottom >= o.bottom))
                overlapping := true
                break

    if not overlapping
        if isHPZ
            obBox := box.new(bar_index[obIdx], obTop, bar_index + 15, obBottom, border_color = color.new(hpzColor, 40), bgcolor = color.new(hpzColor, 80), border_width = 1, border_style = line.style_dashed)
            obPoc := line.new(bar_index[obIdx], obPOC, bar_index + 15, obPOC, color = color.new(hpzColor, 40), width = 1, style = line.style_dashed)
        else
            obBox := box.new(bar_index[obIdx], obTop, bar_index + 15, obBottom, border_color = color.new(baseColor, 60), bgcolor = color.new(baseColor, 85), border_style = line.style_dashed, border_width = 1)
            obPoc := line.new(bar_index[obIdx], obPOC, bar_index + 15, obPOC, color = color.new(baseColor, 70), style = line.style_dashed, width = 1)

        obLabel := label.new(bar_index + 18, obPOC, str.tostring(score, "#") + "%", color = color.new(baseColor, 100), textcolor = isHPZ ? hpzColor : baseColor, style = label.style_none, size = size.tiny, textalign = text.align_left)

        OrderBlock newOB = OrderBlock.new(obBox, obLabel, obPoc, score, obTop, obBottom, isMSBBull, isHPZ, false, 0)
        obArray.push(newOB)

    if isMSBBull 
        lastPh := na 
    else 
        lastPl := na

// IFVG Detection Logic
if showIfvgInput
    // Track potential gaps that haven't inverted yet
    bool fvgBull = low > high[2] and volPercent[1] >= ifvgVolThresholdInput
    bool fvgBear = high < low[2] and volPercent[1] >= ifvgVolThresholdInput

    if fvgBull
        ifvgArray.push(InversionFVG.new(na, na, low, high[2], true, false, false, bar_index[2]))
    if fvgBear
        ifvgArray.push(InversionFVG.new(na, na, low[2], high, false, false, false, bar_index[2]))

// Dynamic Management
var float totalMitigated = 0.0
var float totalObs = 0.0

if (isMSBBull or isMSBBear)
    totalObs += 1

// Update Order Blocks
if obArray.size() > 0
    int mitCount = 0
    for i = obArray.size() - 1 to 0
        OrderBlock ob = obArray.get(i)
        if not ob.mitigated
            ob.boxId.set_right(bar_index + 15)
            ob.labelId.set_x(bar_index + 18)
            ob.pocLineId.set_x2(bar_index + 15)

            bool isMitigated = ob.isBull ? low < ob.bottom : high > ob.top
            if isMitigated
                ob.mitigated := true
                ob.mitigationBar := bar_index
                totalMitigated += 1
                if modeInput == "Present"
                    ob.boxId.delete()
                    ob.labelId.delete()
                    ob.pocLineId.delete()
                else
                    ob.boxId.set_bgcolor(color.new(NEUTRAL_COLOR, 90))
                    ob.boxId.set_border_color(color.new(NEUTRAL_COLOR, 70))
                    ob.labelId.set_textcolor(color.new(NEUTRAL_COLOR, 50))
                    ob.pocLineId.set_color(color.new(NEUTRAL_COLOR, 80))

                    ob.boxId.set_right(bar_index)
                    ob.labelId.set_x(bar_index)
                    ob.pocLineId.set_x2(bar_index)
        else
            mitCount += 1
            bool shouldExtend = extendBrokenInput and mitCount <= 2 and (bar_index - ob.mitigationBar <= 50)
            if modeInput == "Present"
                ob.boxId.delete()
                ob.labelId.delete()
                ob.pocLineId.delete()
            else if shouldExtend
                ob.boxId.set_right(bar_index + 15)
                ob.labelId.set_x(bar_index + 18)
                ob.pocLineId.set_x2(bar_index + 15)
            else
                ob.boxId.set_right(ob.mitigationBar)
                ob.labelId.set_x(ob.mitigationBar)
                ob.pocLineId.set_x2(ob.mitigationBar)

    if obArray.size() > obCountInput
        OrderBlock oldOB = obArray.shift()
        oldOB.boxId.delete()
        oldOB.labelId.delete()
        oldOB.pocLineId.delete()

// Update IFVGs
if ifvgArray.size() > 0
    for i = ifvgArray.size() - 1 to 0
        InversionFVG fvg = ifvgArray.get(i)
        
        if not fvg.inverted
            // Check for inversion (Close through the gap)
            bool isInversion = fvg.isBullGap ? close < fvg.bottom : close > fvg.top
            if isInversion
                fvg.inverted := true
                color ifvgCol      = fvg.isBullGap ? ifvgBearColorInput : ifvgBullColorInput
                color textCol      = fvg.isBullGap ? BEAR_COLOR : BULL_COLOR
                float avgY         = math.avg(fvg.top, fvg.bottom)
                
                fvg.boxId   := box.new(fvg.startBar, fvg.top, bar_index + 10, fvg.bottom, border_color = color.new(ifvgCol, 50), bgcolor = ifvgCol)
                fvg.labelId := label.new(bar_index + 4, avgY, "IFVG", color = #00000000, textcolor = textCol, style = label.style_label_center, size = size.tiny)
            else if bar_index - fvg.startBar > 100 // Remove old un-inverted gaps
                ifvgArray.remove(i)
        
        else if not fvg.mitigated
            fvg.boxId.set_right(bar_index + 10)
            fvg.labelId.set_x(math.round(math.avg(fvg.boxId.get_left(), bar_index + 10)))
            
            // Mitigation check (Re-test of the inverted zone)
            // Bull IFVG (Resistance turned support): Low touches bottom
            // Bear IFVG (Support turned resistance): High touches top
            bool isMitigated = fvg.isBullGap ? high > fvg.top : low < fvg.bottom 
            
            if isMitigated
                fvg.mitigated := true
                if modeInput == "Present"
                    fvg.boxId.delete()
                    fvg.labelId.delete()
                else
                    fvg.boxId.set_bgcolor(color.new(NEUTRAL_COLOR, 90))
                    fvg.boxId.set_border_color(color.new(NEUTRAL_COLOR, 70))
                    fvg.boxId.set_right(bar_index)
                    fvg.labelId.set_textcolor(color.new(NEUTRAL_COLOR, 50))
                    fvg.labelId.set_x(math.round(math.avg(fvg.boxId.get_left(), bar_index)))
        else
            if modeInput == "Present"
                fvg.boxId.delete()
                fvg.labelId.delete()

    // Limit active IFVGs
    int activeCount = 0
    for i = ifvgArray.size() - 1 to 0
        if ifvgArray.get(i).inverted and not ifvgArray.get(i).mitigated
            activeCount += 1
            if activeCount > maxIfvgInput
                InversionFVG old = ifvgArray.get(i)
                old.boxId.delete()
                old.labelId.delete()
                ifvgArray.remove(i)

//---------------------------------------------------------------------------------------------------------------------}
// Visuals
//---------------------------------------------------------------------------------------------------------------------{
// Analytics Dashboard
var table t_able = table.new(parsedDashboardPosition, 2, 5
     , bgcolor          = BACKGROUND    
     , border_width     = 0    
     , frame_color      = BORDERS
     , frame_width      = 1
     , force_overlay    = false)

if showStatsInput and barstate.islast
    float efficiency = totalObs > 0 ? (totalMitigated / totalObs) * 100 : 0
    int hpzs = 0
    if obArray.size() > 0
        for i = 0 to obArray.size() - 1
            if obArray.get(i).isHPZ and not obArray.get(i).mitigated
                hpzs += 1

    t_able.merge_cells(0, 0, 1, 0)
    cell(t_able, 0, 0, 'Statistic Analysis', color = DATA, align = text.align_center)
    cell(t_able, 0, 0, 'Statistics', color = DATA, align = text.align_center)
    divider(t_able, 1, 1)
    cell(t_able, 0, 2, 'Reliability', color = HEADERS, align = text.align_left)
    cell(t_able, 1, 2, str.tostring(efficiency, "#.#") + "%", color = efficiency > 50 ? BULL_COLOR : BEAR_COLOR)
    divider(t_able, 3, 1)
    cell(t_able, 0, 4, 'HP-OB Count', color = HEADERS, align = text.align_left)
    cell(t_able, 1, 4, str.tostring(hpzs), color = DATA)
````

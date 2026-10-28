# LiquidityEdge | DepthFlow Suite

- url: https://www.tradingview.com/script/OlwKY4K1-LiquidityEdge-DepthFlow-Suite/
- type: indicator
- pine_id: PUB;4353457bbd2a48879c39a655b87c7734
- version: 1.0

## Description

The LiquidityEdge | DepthFlow Suite - This script focuses on identifying high-probability liquidity zones based on volume composition and pivot points.

Key Features:
DepthFlow Volume Analysis: The script uses request.security_lower_tf to analyze volume at a deeper level (intra-bar). It calculates the ratio of buying vs. selling volume within specific price areas to determine "Dominance."
Graded Zone System: Zones are automatically graded (A+, A, B, or C) based on the volume dominance percentage. Higher grades indicate stronger institutional interest or "liquidity edge" at that level.
Dynamic Zone Management: Zones are projected forward until price breaches them (invalidated by either a "Touch" or a "Close" depending on your settings).
Session Overlays: Includes automated range boxes for the Asia, London, and New York sessions to help you identify liquidity raids across different trading windows.
Real-time Dashboard: A table in the top-right corner displays the current volume dominance and total volume for the active bar.
Usage Tips:
Lower Timeframe (LTF) Source: Ensure the "Volume Composition TF" in the inputs is set lower than your chart timeframe for accurate DepthFlow analysis (e.g., use "1 minute" while on a 15-minute chart).
Invalidation: You can toggle between "Close" and "Touch" for zone invalidation. "Close" is generally more conservative and waits for a candle to close beyond the zone.
Entry & Stop Guides: You can enable entry/stop lines in the "Entry & Stop Guides" section of the inputs to help visualize potential trade setups near these zones.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("LiquidityEdge | DepthFlow Suite", shorttitle="LiquidityEdge", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// --- Constants ---
var string GRP_LE      = "LIQUIDITYEDGE"
var string GRP_GRADED  = "GRADED ZONE SYSTEM"
var string GRP_HTF     = "HTF LIQUIDITYEDGE ZONES"
var string GRP_FILTERS = "QUALITY FILTERS"
var string GRP_GUIDE   = "ENTRY & STOP GUIDES"
var string GRP_SESS    = "SESSION RANGE OVERLAYS"

// --- Inputs ---
int swingLenInput     = input.int(2, "Swing Length", minval=1, group=GRP_LE, tooltip="Number of bars on each side of the pivot.")
string invalidInput    = input.string("Close", "Invalidation", options=["Close", "Touch"], group=GRP_LE, tooltip="Determine when a zone is considered broken.")
int extendBarsInput    = input.int(100, "Extend Zones (bars)", minval=0, group=GRP_LE, tooltip="How many bars to project the zone forward.")
bool hideInvalidInput  = input.bool(true, "Hide Invalidated", group=GRP_LE, tooltip="Remove zones once price has breached them.")

bool showGradesInput   = input.bool(true, "Show Big Grade Letters", group=GRP_GRADED)
string gradeSizeInput  = input.string("normal", "Big Grade Size", options=["tiny", "small", "normal", "large", "huge"], group=GRP_GRADED)

string ltfSourceInput  = input.timeframe("1", "Volume Composition TF", group=GRP_HTF, tooltip="Timeframe used to calculate bull/bear dominance within zones.")
float dominanceThresh  = input.float(60.0, "Dominance Threshold (%)", minval=50, maxval=100, group=GRP_FILTERS, tooltip="Minimum percentage of volume on one side to color the zone.")
float minVolThresh     = input.float(0.0, "Min Total Volume", minval=0, group=GRP_FILTERS, tooltip="Filter out zones with low total volume.")

bool showGuidesInput   = input.bool(false, "Show Entry & Stop Lines", group=GRP_GUIDE)
int tickOffsetInput    = input.int(10, "Stop Loss Offset (Ticks)", minval=0, group=GRP_GUIDE)

bool showSessionsInput = input.bool(true, "Show Session Overlays", group=GRP_SESS)
string asiaSessInput   = input.session("1900-0400", "Asia Session", group=GRP_SESS)
string lonSessInput    = input.session("0300-1200", "London Session", group=GRP_SESS)
string nySessInput     = input.session("0800-1700", "New York Session", group=GRP_SESS)

// --- Types & Storage ---
type Zone
    box    boxId
    label  labelId
    line   entryLine
    line   stopLine
    float  top
    float  bottom
    float  vol
    float  domRatio
    bool   isBull
    bool   isValid = true
    int    startBar

var Zone[] zonesArray = array.new<Zone>()

// --- Functions ---
get_grade(float ratio) =>
    ratio >= 85 ? "A+" : ratio >= 75 ? "A" : ratio >= 65 ? "B" : "C"

// --- Logic: DepthFlow Volume Analysis ---
float[] ltfClose = request.security_lower_tf(syminfo.tickerid, ltfSourceInput, close)
float[] ltfVol   = request.security_lower_tf(syminfo.tickerid, ltfSourceInput, volume)

float currentBullVol = 0.0
float currentBearVol = 0.0

if array.size(ltfClose) > 0
    for i = 0 to array.size(ltfClose) - 1
        float c = array.get(ltfClose, i)
        float v = array.get(ltfVol, i)
        float prevC = i > 0 ? array.get(ltfClose, i-1) : c
        if c >= prevC
            currentBullVol += v
        else
            currentBearVol += v

float totalVol = currentBullVol + currentBearVol
float bullRatio = totalVol > 0 ? (currentBullVol / totalVol) * 100 : 0
float bearRatio = totalVol > 0 ? (currentBearVol / totalVol) * 100 : 0
bool isDominantBull = bullRatio > bearRatio

// --- Pivot Detection ---
float ph = ta.pivothigh(high, swingLenInput, swingLenInput)
float pl = ta.pivotlow(low, swingLenInput, swingLenInput)

if (not na(ph) or not na(pl)) and totalVol >= minVolThresh
    float top    = not na(ph) ? high[swingLenInput] : low[swingLenInput] + syminfo.mintick * 10
    float bottom = not na(ph) ? high[swingLenInput] - syminfo.mintick * 10 : low[swingLenInput]
    bool isBullZone = not na(ph) ? false : true
    float dom      = isBullZone ? bullRatio : bearRatio
    
    if dom >= dominanceThresh
        color zoneCol = isBullZone ? color.new(#089981, 70) : color.new(#f23645, 70)
        color textCol = isBullZone ? #089981 : #f23645
        
        box b = box.new(bar_index[swingLenInput], top, bar_index + extendBarsInput, bottom, 
             bgcolor=zoneCol, border_color=color.new(textCol, 50))
        
        string grade = get_grade(dom)
        label l = label.new(bar_index + extendBarsInput, (top + bottom) / 2, 
             text = str.format("{0}\n{1}K", grade, math.round(totalVol / 1000, 2)), 
             style=label.style_label_left, color=#00000000, textcolor=textCol, size=gradeSizeInput)
        
        line en = na
        line st = na
        if showGuidesInput
            float entryPrice = isBullZone ? top : bottom
            float stopPrice  = isBullZone ? bottom - (tickOffsetInput * syminfo.mintick) : top + (tickOffsetInput * syminfo.mintick)
            en := line.new(bar_index, entryPrice, bar_index + extendBarsInput, entryPrice, color=chart.fg_color, style=line.style_dashed)
            st := line.new(bar_index, stopPrice, bar_index + extendBarsInput, stopPrice, color=color.new(#f23645, 50), style=line.style_dotted)

        array.push(zonesArray, Zone.new(b, l, en, st, top, bottom, totalVol, dom, isBullZone, true, bar_index[swingLenInput]))

// --- Zone Management ---
if array.size(zonesArray) > 0
    for i = array.size(zonesArray) - 1 to 0
        Zone z = array.get(zonesArray, i)
        if z.isValid
            bool breached = false
            if invalidInput == "Close"
                breached := z.isBull ? close < z.bottom : close > z.top
            else
                breached := z.isBull ? low < z.bottom : high > z.top
            
            if breached
                z.isValid := false
                if hideInvalidInput
                    box.delete(z.boxId)
                    label.delete(z.labelId)
                    line.delete(z.entryLine)
                    line.delete(z.stopLine)
            else
                box.set_right(z.boxId, bar_index + 10)
                label.set_x(z.labelId, bar_index + 10)
                if showGuidesInput and not na(z.entryLine)
                    line.set_x2(z.entryLine, bar_index + 10)
                    line.set_x2(z.stopLine, bar_index + 10)

// --- Sessions Logic ---
var box asiaBox = na
var box lonBox  = na
var box nyBox   = na

if showSessionsInput
    bool inAsia = not na(time(timeframe.period, asiaSessInput, "UTC-5"))
    bool inLon  = not na(time(timeframe.period, lonSessInput, "UTC-5"))
    bool inNY   = not na(time(timeframe.period, nySessInput, "UTC-5"))

    if inAsia and not inAsia[1]
        asiaBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#5b9cf6, 95), border_color=color.new(#5b9cf6, 80), text="ASIA", text_size=size.tiny, text_color=#5b9cf6)
    else if inAsia and not na(asiaBox)
        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, math.max(high, box.get_top(asiaBox)))
        box.set_bottom(asiaBox, math.min(low, box.get_bottom(asiaBox)))

    if inLon and not inLon[1]
        lonBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#089981, 95), border_color=color.new(#089981, 80), text="LON", text_size=size.tiny, text_color=#089981)
    else if inLon and not na(lonBox)
        box.set_right(lonBox, bar_index)
        box.set_top(lonBox, math.max(high, box.get_top(lonBox)))
        box.set_bottom(lonBox, math.min(low, box.get_bottom(lonBox)))

    if inNY and not inNY[1]
        nyBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(#f23645, 95), border_color=color.new(#f23645, 80), text="NY", text_size=size.tiny, text_color=#f23645)
    else if inNY and not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, math.max(high, box.get_top(nyBox)))
        box.set_bottom(nyBox, math.min(low, box.get_bottom(nyBox)))

// --- Dashboard Readout ---
var table board = table.new(position.top_right, 2, 2, bgcolor=chart.bg_color, border_width=1, border_color=chart.fg_color)
if barstate.islast
    table.cell(board, 0, 0, "Dominance", text_color=chart.fg_color)
    table.cell(board, 1, 0, str.format("{0}% {1}", math.round(math.max(bullRatio, bearRatio), 1), isDominantBull ? "BULL" : "BEAR"), text_color = isDominantBull ? #089981 : #f23645)
    table.cell(board, 0, 1, "Total Vol", text_color=chart.fg_color)
    table.cell(board, 1, 1, str.format("{0}K", math.round(totalVol / 1000, 2)), text_color=chart.fg_color)
````

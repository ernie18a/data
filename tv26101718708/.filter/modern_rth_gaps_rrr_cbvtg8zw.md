# Modern RTH Gaps (RRR)

- url: https://www.tradingview.com/script/cBvTG8zW-Modern-RTH-Gaps-RRR/
- type: indicator
- pine_id: PUB;8f0e9663d0204b9582bb84ca699e35ce
- version: 1.0

## Description

Title: Modern RTH Gaps (Dynamic ETH Fills)
Tags: Gaps, Price Action, Liquidity, ICT, Smart Money, Options

Description:

Overview
The "Modern RTH Gaps" indicator is designed for serious index and equity traders who rely on "True Gaps" to locate high-probability liquidity voids. While standard gap indicators simply measure from candle to candle, this script accurately mimics how institutional volume treats market gaps.

The "Modern" Gap Methodology

Creation (RTH Only): True gaps are formed between the final high-volume print of the day and the opening bell. On intraday charts, this script explicitly captures the 16:00 Regular Trading Hours (RTH) Close, freezes that price, and measures the gap against the 09:30 RTH Open.

Destruction (ETH + RTH): Once the gap is established, price is price. This script utilizes dynamic box routing to continuously shrink and update the gap utilizing all price action, including Extended Trading Hours (ETH) wicks that dip into the liquidity zone.

Key Features

Dynamic Price Labels: As a gap shrinks during the session, the Supply/Demand text labels update in real-time to reflect the new, narrower price boundaries—perfect for dialing in intraday options strikes or precise limit orders.

Hybrid Timeframe Engine: Unlike strict session scripts that crash or disappear on higher timeframes, this indicator features a smart router. If you zoom out to a Daily or Weekly chart (which lack ETH data), it seamlessly falls back to standard Open/Close calculations so your chart remains intact.

Memory Efficient: Built from the ground up using Pine Script v6 arrays and types. Closed or expired gaps are instantly purged from both the chart and the engine's memory stack, leaving zero ghost objects behind.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RickyRicardo18

//@version=6
indicator("Modern RTH Gaps (RRR)", shorttitle="Modern Gaps", overlay = true, max_boxes_count = 500)

// MODERN RTH GAPS (HYBRID TIMEFRAMES)
// -----------------------------------
// Intraday Charts: Utilizes "Modern" RTH/ETH logic. Measures from the exact 16:00 Close 
// to the 09:30 Open, and dynamically shrinks boxes during both ETH and RTH sessions.
// 
// Daily+ Charts: Automatically adapts to higher timeframes by comparing the current bar's 
// Open to the previous bar's Close.

// --- User Inputs ---
lookbackDays = input.int(30, title="Scan Period (Trading Days)", minval=1, group="Time Settings", tooltip="Limits how many days back the script will scan for unfilled gaps. Older gaps are automatically cleared from the chart.")

colorUp = input.color(color.new(color.teal, 75), title="Gap Up Color (Demand)", group="Style Settings")
colorDown = input.color(color.new(color.maroon, 75), title="Gap Down Color (Supply)", group="Style Settings")

showBorders = input.bool(true, title="Show Box Borders", group="Style Settings", tooltip="Adds a solid border to the gap zones for crisper price levels.")
showLabels = input.bool(true, title="Show 'Supply/Demand' Text", group="Label Settings")
showPrices = input.bool(true, title="Show Price Levels", group="Label Settings", tooltip="Displays the exact top and bottom coordinates of the gap. Updates dynamically as the gap shrinks.")
textColor = input.color(color.new(color.white, 30), title="Label Text Color", group="Label Settings")

// --- Custom Types ---
type Gap
    float top
    float bottom
    bool  isUp
    int   birthDay
    box   id

// --- State Variables ---
var array<Gap> openGaps     = array.new<Gap>()
var int        dayCount     = 0
var float      prevRTHClose = na

// --- Timeframe & Session Detection ---
bool isIntraday = timeframe.isintraday
bool inRTH      = session.ismarket
bool isNewDay   = ta.change(time("D")) != 0

// Trigger conditions differ based on timeframe
bool isFirstRTHBar = isIntraday ? (inRTH and (not inRTH[1] or isNewDay)) : true

// --- Helper Function: Generate Label Text ---
method getLabelText(Gap g, bool sLabels, bool sPrices) =>
    string txt = ""
    if sLabels
        txt := g.isUp ? "Demand" : "Supply"
    if sPrices
        string priceStr = str.tostring(g.top, format.mintick) + " - " + str.tostring(g.bottom, format.mintick)
        txt := txt == "" ? priceStr : txt + "\n" + priceStr
    txt

// --- 1. Gap Detection ---
if isFirstRTHBar
    dayCount += 1
    
    float currOpen = open
    float refClose = isIntraday ? prevRTHClose : close[1]
    
    if not na(refClose)
        bool isGapUp   = currOpen > refClose
        bool isGapDown = currOpen < refClose
        
        float top    = isGapUp ? currOpen : refClose
        float bottom = isGapUp ? refClose : currOpen
        
        if (isGapUp or isGapDown) and (top > bottom)
            color boxColor = isGapUp ? colorUp : colorDown
            color bdrColor = showBorders ? color.new(boxColor, 0) : na
            
            Gap newGap = Gap.new(top, bottom, isGapUp, dayCount, box(na))
            string boxText = newGap.getLabelText(showLabels, showPrices)
            
            newGap.id := box.new(left=bar_index, top=top, right=bar_index, bottom=bottom, border_color=bdrColor, bgcolor=boxColor, text=boxText, text_color=textColor, text_halign=text.align_right, text_valign=text.align_center, text_size=size.small)
            openGaps.push(newGap)

// Cache the RTH close for intraday logic
if isIntraday and inRTH
    prevRTHClose := close

// --- 2. Gap Management (Shrinking & Deletion) ---
if openGaps.size() > 0
    for i = openGaps.size() - 1 to 0
        Gap g = openGaps.get(i)
        
        g.id.set_right(bar_index)
        
        bool isClosed = false
        bool isShrunk = false
        
        if g.isUp
            if low < g.top
                g.top := low
                g.id.set_top(g.top)
                isShrunk := true
            if low <= g.bottom
                isClosed := true
        else
            if high > g.bottom
                g.bottom := high
                g.id.set_bottom(g.bottom)
                isShrunk := true
            if high >= g.top
                isClosed := true
                
        // If the gap shrunk but didn't close, update the price label dynamically
        if isShrunk and not isClosed and showPrices
            g.id.set_text(g.getLabelText(showLabels, showPrices))
                
        bool isExpired = (dayCount - g.birthDay) > lookbackDays
        
        if isClosed or isExpired
            g.id.delete()
            openGaps.remove(i)
````

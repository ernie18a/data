# SkaleHub Zones [Level 2]

- url: https://www.tradingview.com/script/OXstRctr-SkaleHub-Zones-Level-2/
- type: indicator
- pine_id: PUB;5fe73990735142c3951411a266eb9ab0
- version: 1.0

## Description

Overview
The first premium tool in the SkaleHub Advanced progression suite. This algorithm mathematically identifies historical pivot points and automatically draws institutional Supply and Demand (Support and Resistance) zones across your chart.

The Edge
Amateurs trade in the middle of nowhere; professionals wait for price to come to areas of high liquidity. This script automates that patience, eliminating the tedious daily routine of manually drawing support and resistance lines, and dynamically adapting as new price action unfolds.

Key Features:

Automated Zone Plotting: Accurately maps out historical swing highs and lows, drawing clean, shaded areas that represent real institutional order blocks.

Smart Mitigation (Auto-Delete): The algorithm extends active zones indefinitely but immediately stops plotting them the moment a candle closes beyond the zone, keeping your chart free of broken, obsolete lines.

Patience Enforcer: Systemizes your trading by visually showing you exactly where to do business. No trades should be taken unless price enters one of these auto-drawn SkaleHub Zones.

How to Use

Apply the indicator to your chart.

Wait for the market to enter a drawn zone.

Do not trade immediately upon entry. Once price enters a Level 2 Zone, drop to a lower timeframe and wait for momentum to shift in your favor before executing.

If a candle closes completely outside a zone, the zone will stop extending. This represents a breakout and a shift in market structure.

Author's Note
This is a premium, Invite-Only script. It is Level 2 of the SkaleHub Training System. To gain access to this script and the subsequent algorithmic trigger tools, your TradingView username must be explicitly authorized through the SkaleHub Academy.

## Source Code

````pine
//@version=5
indicator("SkaleHub Zones [Level 2]", overlay=true, max_boxes_count=100)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
leftBars  = input.int(15, title="Left Lookback", minval=1, group="Zone Structure", tooltip="Bars needed to confirm a swing point.")
rightBars = input.int(15, title="Right Lookback", minval=1, group="Zone Structure", tooltip="Bars passed before the zone is printed.")

c_sup     = input.color(color.new(#00ff00, 85), title="Demand/Support Zone Color", group="Visuals")
c_res     = input.color(color.new(#ff0000, 85), title="Supply/Resistance Zone Color", group="Visuals")
borderW   = input.int(1, title="Border Width", minval=0, maxval=3, group="Visuals")

// =========================================================================
// 2. MATH & DATA FETCHING (Pivot Recognition)
// =========================================================================
// Identify structural swing highs and swing lows
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

// Arrays to store active, unmitigated zones
var box[] activeSup = array.new_box()
var box[] activeRes = array.new_box()

// =========================================================================
// 3. ZONE CREATION LOGIC
// =========================================================================
// When a new Pivot High is confirmed, draw a new Supply (Resistance) Zone
if not na(ph)
    // The top of the zone is the extreme high wick. The bottom is the highest body (open or close).
    top = high[rightBars]
    bot = math.max(open[rightBars], close[rightBars])
    
    // Create the box starting at the pivot candle and push it to the active array
    b = box.new(left=bar_index[rightBars], top=top, right=bar_index, bottom=bot, border_color=color.new(c_res, 30), border_width=borderW, bgcolor=c_res)
    array.push(activeRes, b)

// When a new Pivot Low is confirmed, draw a new Demand (Support) Zone
if not na(pl)
    // The bottom of the zone is the extreme low wick. The top is the lowest body (open or close).
    bot = low[rightBars]
    top = math.min(open[rightBars], close[rightBars])
    
    // Create the box starting at the pivot candle and push it to the active array
    b = box.new(left=bar_index[rightBars], top=top, right=bar_index, bottom=bot, border_color=color.new(c_sup, 30), border_width=borderW, bgcolor=c_sup)
    array.push(activeSup, b)

// =========================================================================
// 4. ZONE EXTENSION & MITIGATION (BREAKOUT) LOGIC
// =========================================================================
// Manage Resistance Zones
if array.size(activeRes) > 0
    for i = array.size(activeRes) - 1 to 0
        b = array.get(activeRes, i)
        
        // Extend the box to the right on every new bar
        box.set_right(b, bar_index)
        
        // Invalidation: If a candle cleanly closes above the top of the supply zone, it is broken. 
        // We remove it from the active array so it stops extending, keeping the chart clean.
        if close > box.get_top(b)
            array.remove(activeRes, i)

// Manage Support Zones
if array.size(activeSup) > 0
    for i = array.size(activeSup) - 1 to 0
        b = array.get(activeSup, i)
        
        // Extend the box to the right on every new bar
        box.set_right(b, bar_index)
        
        // Invalidation: If a candle cleanly closes below the bottom of the demand zone, it is broken.
        if close < box.get_bottom(b)
            array.remove(activeSup, i)
````

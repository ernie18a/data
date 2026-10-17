# AndrewTrades Fair Value Gap (FVG)

- url: https://www.tradingview.com/script/IPsnvdtA-AndrewTrades-Fair-Value-Gap-FVG/
- type: indicator
- pine_id: PUB;f39c099e863d48a79c3f90c1941734cd
- version: 1.0

## Description

The indicator automatically detects and highlights bullish and bearish Fair Value Gaps (FVGs) directly on the chart. It merges stacked FVGs into cleaner zones, dynamically extends them forward, and removes zones once they are fully mitigated by price.

## Source Code

````pine
//@version=6
indicator("AndrewTrades Fair Value Gap (FVG)", shorttitle = "AndrewTrades FVG", overlay = true, max_boxes_count = 500)

// ─────────────────────────────────────────────
// USER INPUTS
// ─────────────────────────────────────────────
grpMain = "Settings"
grpStyle   = "Style"

maxZones   = input.int(50, "Max Displayed FVGs", minval = 1, maxval = 500, group = grpMain)
extendBars = input.int(20, "Extend Boxes (bars)", minval = 0, maxval = 500, group = grpMain)

bullCol    = input.color(color.new(color.green, 70), "Bullish FVG Color", group = grpStyle)
bearCol    = input.color(color.new(color.red,   70), "Bearish FVG Color", group = grpStyle)

// ─────────────────────────────────────────────
// ZONE STATE ARRAYS
// ─────────────────────────────────────────────
var box[]   zBox   = array.new<box>()
var float[] zTop   = array.new<float>()
var float[] zBot   = array.new<float>()
var int[]   zLeft  = array.new<int>()
var int[]   zRight = array.new<int>()
var bool[]  zBull  = array.new<bool>()

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
removeZone(int i) =>
    box.delete(array.get(zBox, i))
    array.remove(zBox,   i)
    array.remove(zTop,   i)
    array.remove(zBot,   i)
    array.remove(zLeft,  i)
    array.remove(zRight, i)
    array.remove(zBull,  i)

addZone(float top, float bot, int leftBar, int rightBar, bool isBull) =>
    b = box.new(
         leftBar, top, rightBar, bot,
         bgcolor = isBull ? bullCol : bearCol,
         border_width = 0
         )
    array.push(zBox,   b)
    array.push(zTop,   top)
    array.push(zBot,   bot)
    array.push(zLeft,  leftBar)
    array.push(zRight, rightBar)
    array.push(zBull,  isBull)

updateZone(int i, float top, float bot) =>
    array.set(zTop, i, top)
    array.set(zBot, i, bot)
    box.set_top(array.get(zBox, i), top)
    box.set_bottom(array.get(zBox, i), bot)

// ─────────────────────────────────────────────
// STEP 1 – DETECT FVG
// ─────────────────────────────────────────────
isBullFVG = high[2] < low[0]
isBearFVG = low[2]  > high[0]

newTop  = isBullFVG ? low[0]  : (isBearFVG ? low[2]  : na)
newBot  = isBullFVG ? high[2] : (isBearFVG ? high[0] : na)
newBull = isBullFVG
newLeft = bar_index - 2

// ─────────────────────────────────────────────
// STEP 2 – ADD OR MERGE ZONES
// ─────────────────────────────────────────────
if (isBullFVG or isBearFVG) and not na(newTop)
    bool merged = false
    size = array.size(zBox)
    
    if size > 0
        // Check if the last zone was created exactly 1 bar ago and is same type
        lastIdx   = size - 1
        lastLeft  = array.get(zLeft, lastIdx)
        lastBull  = array.get(zBull, lastIdx)
        
        // A "stacked" FVG happens when the new FVG's left edge (bar_index-2) 
        // is exactly 1 bar after the previous FVG's left edge (lastLeft + 1)
        if newLeft == lastLeft + 1 and newBull == lastBull
            merged := true
            // Expand the existing zone to cover the new gap
            mTop = math.max(newTop, array.get(zTop, lastIdx))
            mBot = math.min(newBot, array.get(zBot, lastIdx))
            updateZone(lastIdx, mTop, mBot)

    if not merged
        while array.size(zBox) >= maxZones
            removeZone(0)
        addZone(newTop, newBot, newLeft, bar_index + extendBars, newBull)

// ─────────────────────────────────────────────
// STEP 3 – UPDATE & MITIGATE
// ─────────────────────────────────────────────
sizeUpdate = array.size(zBox)
if sizeUpdate > 0
    for i = sizeUpdate - 1 to 0
        top    = array.get(zTop,  i)
        bot    = array.get(zBot,  i)
        isBull = array.get(zBull, i)

        // Keep extending the right side
        newRight = bar_index + extendBars
        array.set(zRight, i, newRight)
        box.set_right(array.get(zBox, i), newRight)

        // Mitigation Logic
        fullyMit = (isBull and low <= bot) or (not isBull and high >= top)
        if fullyMit
            removeZone(i)
````

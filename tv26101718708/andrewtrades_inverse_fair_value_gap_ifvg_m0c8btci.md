# AndrewTrades Inverse Fair Value Gap (iFVG)

- url: https://www.tradingview.com/script/m0c8btcI-AndrewTrades-Inverse-Fair-Value-Gap-iFVG/
- type: indicator
- pine_id: PUB;ae78d8188ce44309b416d9764224209d
- version: 1.0

## Description

[b]AndrewTrades Inverse Fair Value Gap (iFVG)[/b] automatically detects and displays Inverted Fair Value Gaps directly on the chart. The indicator first tracks standard bullish and bearish FVGs, then converts them into inverse FVG zones once price closes through the gap, which can be used as support/resistance zones.

Bullish iFVG → Created when price closes above a bearish FVG
Bearish iFVG → Created when price closes below a bullish FVG

## Source Code

````pine
//@version=6
indicator("AndrewTrades Inverse Fair Value Gap (iFVG)", shorttitle = "AndrewTrades iFVG", overlay = true, max_boxes_count = 500)

// ─────────────────────────────────────────────
// USER INPUTS
// ─────────────────────────────────────────────
grpMain  = "Settings"
grpStyle  = "Style"

maxZones   = input.int(50, "Max Displayed iFVGs", minval = 1, maxval = 500, group = grpMain)
extendBars = input.int(20, "Extend Boxes (bars)", minval = 0, maxval = 500, group = grpMain)

bullCol   = input.color(color.new(color.green, 70), "Bullish iFVG", group = grpStyle)
bearCol   = input.color(color.new(color.red,   70), "Bearish iFVG", group = grpStyle)

// ─────────────────────────────────────────────
// ARRAYS FOR UNFILLED "GHOST" FVGs
// ─────────────────────────────────────────────
var float[] gTop   = array.new<float>()
var float[] gBot   = array.new<float>()
var int[]   gLeft  = array.new<int>()
var bool[]  gBull  = array.new<bool>()

// ─────────────────────────────────────────────
// ARRAYS FOR ACTIVE iFVG ZONES
// ─────────────────────────────────────────────
var box[]   zBox   = array.new<box>()
var float[] zTop   = array.new<float>()
var float[] zBot   = array.new<float>()
var bool[]  zBull  = array.new<bool>()

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
removeIFVG(int i) =>
    box.delete(array.get(zBox, i))
    array.remove(zBox,  i)
    array.remove(zTop,  i)
    array.remove(zBot,  i)
    array.remove(zBull, i)

addIFVG(float top, float bot, int leftBar, bool isBull) =>
    if array.size(zBox) >= maxZones
        removeIFVG(0)
    
    b = box.new(
         leftBar, top, bar_index + extendBars, bot,
         bgcolor = isBull ? bullCol : bearCol,
         border_width = 0
         )
    array.push(zBox,  b)
    array.push(zTop,  top)
    array.push(zBot,  bot)
    array.push(zBull, isBull)

// ─────────────────────────────────────────────
// STEP 1 – DETECT STANDARD FVGs (Ghost Mode)
// ─────────────────────────────────────────────
isBullFVG = high[2] < low[0]
isBearFVG = low[2]  > high[0]

if isBullFVG
    array.push(gTop,  low[0])
    array.push(gBot,  high[2])
    array.push(gLeft, bar_index - 2)
    array.push(gBull, true)

if isBearFVG
    array.push(gTop,  low[2])
    array.push(gBot,  high[0])
    array.push(gLeft, bar_index - 2)
    array.push(gBull, false)

// ─────────────────────────────────────────────
// STEP 2 – CHECK FOR INVERSION
// ─────────────────────────────────────────────
if array.size(gTop) > 0
    for i = array.size(gTop) - 1 to 0
        top    = array.get(gTop, i)
        bot    = array.get(gBot, i)
        left   = array.get(gLeft, i)
        isBull = array.get(gBull, i)
        
        inversed = false
        // Bearish iFVG: Price closes below a Bullish FVG
        if isBull and close < bot
            addIFVG(top, bot, left, false)
            inversed := true
        
        // Bullish iFVG: Price closes above a Bearish FVG
        else if not isBull and close > top
            addIFVG(top, bot, left, true)
            inversed := true
            
        if inversed
            array.remove(gTop,  i)
            array.remove(gBot,  i)
            array.remove(gLeft, i)
            array.remove(gBull, i)

// ─────────────────────────────────────────────
// STEP 3 – UPDATE & INVALIDATE iFVGs
// ─────────────────────────────────────────────
sizeUpdate = array.size(zBox)

if sizeUpdate > 0
    for i = sizeUpdate - 1 to 0
        top     = array.get(zTop, i)
        bot     = array.get(zBot, i)
        isIBull = array.get(zBull, i)

        box.set_right(array.get(zBox, i), bar_index + extendBars)

        // Remove only on candle-close invalidation
        invalidated =
             (isIBull and close < bot) or
             (not isIBull and close > top)

        if invalidated
            removeIFVG(i)
````

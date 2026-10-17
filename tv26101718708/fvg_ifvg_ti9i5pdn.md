# FVG + IFVG

- url: https://www.tradingview.com/script/Ti9i5PdN-FVG-IFVG/
- type: indicator
- pine_id: PUB;57c930f8a1d640b2838390941a3cb200
- version: 1.0

## Description

finding FVG and IFVg on the charts to help wiht market anasylis for both bearish and bullish

## Source Code

````pine
//@version=6
indicator("FVG + IFVG", overlay=true, max_boxes_count=500)

//====================
// Inputs - FVG
//====================
grpFVG = "FVG Settings"
showBullish   = input.bool(true, "Show bullish FVGs", group=grpFVG)
showBearish   = input.bool(true, "Show bearish FVGs", group=grpFVG)
minGapTicks   = input.int(1, "Minimum gap in ticks", minval=1, group=grpFVG)
extendBars    = input.int(1, "Extend boxes right", minval=1, maxval=500, group=grpFVG)

bullColor     = input.color(color.new(color.green, 82), "Bullish FVG color", group=grpFVG)
bearColor     = input.color(color.new(color.red, 82), "Bearish FVG color", group=grpFVG)
borderColor   = input.color(color.new(color.gray, 100), "FVG border color", group=grpFVG)

//====================
// Inputs - IFVG
//====================
grpIFVG = "IFVG Settings"
showIFVG          = input.bool(true,  "Show IFVGs", group=grpIFVG)
ifvgExtendBars    = input.int(20,     "IFVG fixed width (bars)", minval=1, maxval=200, group=grpIFVG,
                     tooltip="IFVG boxes stop here — they do not extend with price. Set how wide the box is.")
invalidateOnClose = input.bool(true,  "Invalidate IFVG on close through opposite side", group=grpIFVG)
maxActiveIFVG     = input.int(30,     "Max IFVGs to track", minval=5, maxval=100, group=grpIFVG)

ifvgBullColor  = input.color(color.new(color.lime, 70),   "Bullish IFVG color", group=grpIFVG)
ifvgBearColor  = input.color(color.new(color.maroon, 70), "Bearish IFVG color", group=grpIFVG)
ifvgBorder     = input.color(color.new(color.white, 40),  "IFVG border color", group=grpIFVG)

//====================
// Gap size
//====================
minGap = minGapTicks * syminfo.mintick

//====================
// FVG logic
//====================
bullFVG = bar_index >= 2 and low > high[2] and (low - high[2]) >= minGap
bearFVG = bar_index >= 2 and high < low[2] and (low[2] - high) >= minGap

//====================
// Draw FVG boxes (original logic — unchanged)
//====================
if showBullish and bullFVG
    box.new(
         left = bar_index - 2,
         top = low,
         right = bar_index + extendBars,
         bottom = high[2],
         bgcolor = bullColor,
         border_color = borderColor
     )

if showBearish and bearFVG
    box.new(
         left = bar_index - 2,
         top = low[2],
         right = bar_index + extendBars,
         bottom = high,
         bgcolor = bearColor,
         border_color = borderColor
     )

//====================
// IFVG TRACKING
//====================
type PendingFVG
    float top
    float bot
    int   dir
    int   bornBar

type ActiveIFVG
    box   bx
    float top
    float bot
    int   dir
    int   endBar  // fixed right edge — does not move

var array<PendingFVG> pending = array.new<PendingFVG>()
var array<ActiveIFVG> ifvgs   = array.new<ActiveIFVG>()

if bullFVG
    PendingFVG p = PendingFVG.new()
    p.top := low
    p.bot := high[2]
    p.dir := 1
    p.bornBar := bar_index
    array.push(pending, p)

if bearFVG
    PendingFVG p = PendingFVG.new()
    p.top := low[2]
    p.bot := high
    p.dir := -1
    p.bornBar := bar_index
    array.push(pending, p)

if array.size(pending) > 100
    array.shift(pending)

//====================
// CHECK FOR INVERSION
//====================
if showIFVG and array.size(pending) > 0
    for i = array.size(pending) - 1 to 0
        PendingFVG p = array.get(pending, i)
        bool flipsBull = p.dir == 1 and close < p.bot
        bool flipsBear = p.dir == -1 and close > p.top

        if flipsBull or flipsBear
            color col = flipsBull ? ifvgBearColor : ifvgBullColor
            int newDir = flipsBull ? -1 : 1
            int fixedRight = bar_index + ifvgExtendBars

            ActiveIFVG ia = ActiveIFVG.new()
            ia.top    := p.top
            ia.bot    := p.bot
            ia.dir    := newDir
            ia.endBar := fixedRight
            ia.bx     := box.new(
                 left         = p.bornBar - 2,
                 top          = p.top,
                 right        = fixedRight,
                 bottom       = p.bot,
                 bgcolor      = col,
                 border_color = ifvgBorder
             )
            array.push(ifvgs, ia)
            array.remove(pending, i)

if array.size(ifvgs) > maxActiveIFVG
    ActiveIFVG old = array.shift(ifvgs)
    box.delete(old.bx)

//====================
// MANAGE ACTIVE IFVGs
// Box right edge is FIXED — no extension
// Only check for invalidation on close-through
//====================
if array.size(ifvgs) > 0
    for i = array.size(ifvgs) - 1 to 0
        ActiveIFVG ia = array.get(ifvgs, i)

        if invalidateOnClose
            bool killBull = ia.dir == 1 and close < ia.bot
            bool killBear = ia.dir == -1 and close > ia.top
            if killBull or killBear
                box.delete(ia.bx)
                array.remove(ifvgs, i)
````

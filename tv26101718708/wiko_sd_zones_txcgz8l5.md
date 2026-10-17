# Wiko S/D Zones

- url: https://www.tradingview.com/script/tXcgZ8L5-Wiko-S-D-Zones/
- type: indicator
- pine_id: PUB;2366448bdb6241c7bfb75fd29a98fdbe
- version: 1.0

## Description

This indicator automatically identifies and plots key Supply and Demand zones directly on your chart, giving you a clear visual edge for finding high-probability trade setups.
Supply zones represent areas where price has previously shown strong selling pressure, while Demand zones mark areas where buyers have stepped in aggressively. These zones act as magnets — price tends to revisit and react to them, making them ideal areas to look for entries, exits, and reversals.
What it does:

Automatically draws Supply zones (resistance areas) and Demand zones (support areas)
Updates in real time as new zones are formed
Clearly color codes zones for quick visual reading — red for Supply, green for Demand
Marks tested zones so you always know which levels have been revisited

How to use it:

Look for price to pull back into a zone and react — that's your entry signal
Use in confluence with your existing bias, structure, and confirmation tools
Works on all timeframes and all instruments

Best used on: Futures, Forex, Crypto, Stocks
Recommended timeframes: 1M, 3M, 5M, 15M, 1H and above

## Source Code

````pine
//@version=6
// =============================================================================
//  WIKO S/D ZONES — Pure supply & demand zone detection
//
//  Just draws the zones. No signals, no entries, no alerts.
//  Wait for price to touch the zone, then take your own decision.
//
//  DEMAND ZONE (green): body of last BEARISH candle before a strong bullish push.
//  SUPPLY ZONE (red):   body of last BULLISH candle before a strong bearish push.
// =============================================================================
indicator("Wiko S/D Zones", shorttitle="Wiko S/D", overlay=true,
     max_boxes_count=300, max_labels_count=300)

// ---------- INPUTS ----------
g_det  = "▸ Detection"
g_mgmt = "▸ Display"

atrLen       = input.int(14,    "ATR length", minval=2, group=g_det)
impulseMult  = input.float(1.5, "Impulse body must be ≥ N × ATR",
     minval=0.5, step=0.1, group=g_det,
     tooltip="Higher = fewer, stronger zones.")
maxLookback  = input.int(5,     "Max bars to look back for the base candle",
     minval=1, maxval=10, group=g_det)
useBodyOnly  = input.bool(true, "Use candle body only (else use full wick range)", group=g_det)
breakOnClose = input.bool(true, "A 'break' requires close beyond the zone", group=g_det)

maxZones     = input.int(12,    "Max active zones per side",
     minval=2, maxval=30, group=g_mgmt)
extendBars   = input.int(50,    "Extend zone right edge by N bars",
     minval=5, maxval=500, group=g_mgmt)
fadeTested   = input.bool(true, "Fade zones once tested", group=g_mgmt)
hideBroken   = input.bool(true, "Hide broken zones immediately", group=g_mgmt)
showLabels   = input.bool(true, "Label zones (FRESH/TESTED)", group=g_mgmt)

colDemandFresh  = input.color(color.new(#26a69a, 70), "Demand FRESH",  group=g_mgmt, inline="d")
colDemandTested = input.color(color.new(#26a69a, 88), "Demand TESTED", group=g_mgmt, inline="d")
colSupplyFresh  = input.color(color.new(#ef5350, 70), "Supply FRESH",  group=g_mgmt, inline="s")
colSupplyTested = input.color(color.new(#ef5350, 88), "Supply TESTED", group=g_mgmt, inline="s")
colBorderD      = input.color(#26a69a, "Demand border", group=g_mgmt, inline="b")
colBorderS      = input.color(#ef5350, "Supply border", group=g_mgmt, inline="b")

// ---------- CORE ----------
atr = ta.atr(atrLen)

// ---------- ZONE STATE ----------
type Zone
    bool  isDemand
    float top
    float bot
    bool  tested
    bool  broken
    box   bx
    label lb

var array<Zone> demandZones = array.new<Zone>()
var array<Zone> supplyZones = array.new<Zone>()

// ---------- HELPERS ----------
f_barTop(int offset) =>
    useBodyOnly ? math.max(open[offset], close[offset]) : high[offset]
f_barBot(int offset) =>
    useBodyOnly ? math.min(open[offset], close[offset]) : low[offset]

f_makeBox(float top, float bot, int leftBar, bool isDemand) =>
    bg = isDemand ? colDemandFresh : colSupplyFresh
    br = isDemand ? colBorderD     : colBorderS
    box.new(left=leftBar, top=top, right=bar_index + extendBars, bottom=bot,
         bgcolor=bg, border_color=color.new(br, 50), border_width=1)

f_makeLabel(float top, int leftBar, bool isDemand) =>
    txt = isDemand ? "Demand · FRESH" : "Supply · FRESH"
    col = isDemand ? colBorderD : colBorderS
    showLabels ? label.new(leftBar, top, txt,
         style = isDemand ? label.style_label_lower_right : label.style_label_upper_right,
         color = color.new(col, 70), textcolor = color.new(col, 0),
         size = size.tiny, yloc = yloc.price) : na

f_markTested(Zone z) =>
    if not na(z.bx)
        newBg = z.isDemand ? colDemandTested : colSupplyTested
        box.set_bgcolor(z.bx, newBg)
    if not na(z.lb)
        newTxt = z.isDemand ? "Demand · TESTED" : "Supply · TESTED"
        label.set_text(z.lb, newTxt)

f_closeVisual(Zone z) =>
    if not na(z.bx)
        if hideBroken
            box.delete(z.bx)
        else
            box.set_right(z.bx, bar_index)
            box.set_bgcolor(z.bx, color.new(color.gray, 92))
            box.set_border_color(z.bx, color.new(color.gray, 60))
    if not na(z.lb)
        if hideBroken
            label.delete(z.lb)

f_pushZone(array<Zone> arr, Zone z) =>
    array.push(arr, z)
    if array.size(arr) > maxZones
        oldest = array.shift(arr)
        if not na(oldest.bx)
            box.delete(oldest.bx)
        if not na(oldest.lb)
            label.delete(oldest.lb)

// ---------- CREATE ZONES ----------
if close[1] > open[1] and math.abs(close[1] - open[1]) >= impulseMult * atr[1]
    int baseIdx = na
    for k = 2 to maxLookback + 1
        if close[k] < open[k]
            baseIdx := k
            break
    if not na(baseIdx)
        top    = f_barTop(baseIdx)
        bot    = f_barBot(baseIdx)
        leftBx = bar_index - baseIdx
        bx     = f_makeBox(top, bot, leftBx, true)
        lb     = f_makeLabel(top, leftBx, true)
        f_pushZone(demandZones, Zone.new(true, top, bot, false, false, bx, lb))

if close[1] < open[1] and math.abs(close[1] - open[1]) >= impulseMult * atr[1]
    int baseIdx = na
    for k = 2 to maxLookback + 1
        if close[k] > open[k]
            baseIdx := k
            break
    if not na(baseIdx)
        top    = f_barTop(baseIdx)
        bot    = f_barBot(baseIdx)
        leftBx = bar_index - baseIdx
        bx     = f_makeBox(top, bot, leftBx, false)
        lb     = f_makeLabel(top, leftBx, false)
        f_pushZone(supplyZones, Zone.new(false, top, bot, false, false, bx, lb))

// ---------- UPDATE ZONES ----------
if array.size(demandZones) > 0
    for i = 0 to array.size(demandZones) - 1
        z = array.get(demandZones, i)
        if not z.broken
            if not na(z.bx)
                box.set_right(z.bx, bar_index + 2)
            touched = low <= z.top and high >= z.bot
            if touched and not z.tested
                z.tested := true
                if fadeTested
                    f_markTested(z)
            brokeIt = breakOnClose ? close < z.bot : low < z.bot
            if brokeIt
                z.broken := true
                f_closeVisual(z)

if array.size(supplyZones) > 0
    for i = 0 to array.size(supplyZones) - 1
        z = array.get(supplyZones, i)
        if not z.broken
            if not na(z.bx)
                box.set_right(z.bx, bar_index + 2)
            touched = high >= z.bot and low <= z.top
            if touched and not z.tested
                z.tested := true
                if fadeTested
                    f_markTested(z)
            brokeIt = breakOnClose ? close > z.top : high > z.top
            if brokeIt
                z.broken := true
                f_closeVisual(z)
````

# Supply and Demand Zones with Market Structure [Jayadev Rana]

- url: https://www.tradingview.com/script/8OlYUTQU-Supply-and-Demand-Zones-with-Market-Structure-Jayadev-Rana/
- type: indicator
- pine_id: PUB;77a894f3689b4dccb3b9462cada736de
- version: 1.0

## Description

Overview
This open-source overlay draws two closely related price-action concepts on a single chart: swing-based supply and demand zones, and market-structure mapping (swing labels, a zig-zag of confirmed swings, and Break of Structure markers). It is a visual analysis aid. It does not generate buy or sell signals, it does not place orders, and it makes no performance claim.

How swings are detected
Every element in the script is anchored to a confirmed swing pivot. Swings are found with symmetric pivots: a swing high requires its high to be the highest of the N bars on its left and the N bars on its right (and the mirror condition for a swing low), where N is the Swing High/Low Length input. Because a pivot needs N bars on both sides to exist, it is only confirmed N bars after the pivot bar. Once a swing is confirmed, its label, zone and zig-zag segment are fixed to that historical bar and do not move or repaint afterwards. The trade-off of this method is a fixed N-bar delay before a swing becomes visible. This is inherent to symmetric pivots and is disclosed here so the behavior is clear.

Supply and demand zones
When a swing high is confirmed, a supply zone is drawn from that swing high down to the top of the swing candle's body. When a swing low is confirmed, a demand zone is drawn from that swing low up to the bottom of the swing candle's body. This anchors each zone on the candle that produced the turning point. Because wick-only zones can be very thin, an optional ATR floor (on by default) gives each zone a minimum thickness equal to a configurable multiple of the 14-period ATR, so zones stay readable across different instruments and timeframes.

Each zone extends to the right until it is mitigated. A supply zone is treated as mitigated when price closes above it; a demand zone when price closes below it. On mitigation the zone is either removed or greyed out, depending on the When a zone is broken input. To respect the platform limit of 500 drawing objects and to keep the chart readable, only the newest N zones per side are retained (the Zones to keep per side input).

Market structure
Swing labels: each confirmed swing is labelled relative to the previous same-side swing. Highs are marked HH (higher high) or LH (lower high); lows are marked HL (higher low) or LL (lower low). Bullish structure (HH, HL) uses the bullish colour and bearish structure (LH, LL) uses the bearish colour.
Zig-zag: consecutive confirmed swings are joined by a line, giving a de-cluttered skeleton of price movement.
Break of Structure (BOS): the most recent confirmed swing high and swing low are tracked as reference levels. The first time price closes above the reference swing high a BOS is marked, and the mirror for a close below the reference swing low. Each level is marked only once.

Dashboard
An optional table in the top-right corner shows the current swing length, the number of active supply and demand zones, and the direction of the last Break of Structure.

Inputs
Structure and Swings: swing length, and toggles for the zig-zag, the swing labels and the BOS markers.
Supply and Demand Zones: master toggle, zones to keep per side, the ATR minimum-thickness option and multiplier, broken-zone handling (remove or grey out), and the right-extension toggle.
Colors: independent fill and border colours for supply, demand and broken zones, the zig-zag colour, and the bullish and bearish structure colours.
Dashboard: show or hide the summary table.

Alerts
Alert conditions are provided for a bullish BOS, a bearish BOS, a new supply zone, and a new demand zone.

How to use it
Supply and demand zones are commonly read as areas where price may react, while market structure (the sequence of HH, HL, LH, LL and BOS events) describes the prevailing trend and its changes. Reading the two layers together, for example a demand zone that coincides with bullish structure or a supply zone that coincides with bearish structure, is one way traders use this kind of tool. This script only draws the levels and the structure. It does not tell you when to enter or exit, and any decision you make is your own.

Originality and scope
This is an original implementation written from scratch. The underlying ideas, namely pivot-based swing detection, supply and demand zones, higher-high and lower-low structure labelling, and break of structure, are long-established public-domain price-action concepts rather than the property of any single author. The purpose of this publication is to combine them into one coherent, fully configurable, non-repainting overlay with readable code and a compact summary dashboard.

Limitations and disclaimer
Swings, and everything derived from them, appear with a fixed N-bar confirmation delay. This is by design and is not an error.
Zone mitigation is evaluated on bar close. On the developing (last) bar, states can still change until the bar closes.
Past behaviour of price around a zone or a structure point does not predict future results. This tool is for education and analysis only and is not financial advice. Test any approach yourself before relying on it.

## Source Code

````pine
//@version=6
// =============================================================================
// Supply and Demand Zones with Market Structure [Jayadev Rana]
// -----------------------------------------------------------------------------
// Original open-source overlay that combines two classic, public-domain
// price-action tools on a single chart:
//   1. Swing-based Supply and Demand zones (order-block style boxes).
//   2. Market structure mapping: HH / HL / LH / LL swing labels, a zig-zag of
//      confirmed swings, and Break of Structure (BOS) markers.
//
// HOW SWINGS ARE FOUND (and why it does not repaint after confirmation):
//   Swings use symmetric pivots (ta.pivothigh / ta.pivotlow). A pivot needs
//   swingLength bars on BOTH sides, so it is only confirmed swingLength bars
//   after it prints. Once drawn, every label, zone and line is anchored to a
//   historical bar and never moves again. The trade-off is a fixed
//   swingLength-bar delay before a swing is confirmed.
//
// ZONES:
//   Supply zone  = confirmed swing high: top = swing high, bottom = top of that
//                  candle's body. Demand zone = confirmed swing low: bottom =
//                  swing low, top = bottom of that candle's body. An optional
//                  ATR floor gives very thin zones a readable minimum height.
//   A zone extends to the right until it is mitigated. Mitigation = price
//   CLOSING beyond the zone (a close above a supply zone, or below a demand
//   zone); the zone is then removed or greyed out per the input. Only the newest
//   N zones per side are kept, to respect the 500 drawing-object limit.
//
// SCOPE: this is purely a visual structure and zone tool. It makes no
// directional prediction, places no orders, and carries no performance claim.
// =============================================================================
indicator("Supply and Demand Zones with Market Structure [Jayadev Rana]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ---------------------------------------------------------------------------
// 1. INPUTS
// ---------------------------------------------------------------------------
grpS         = "Structure and Swings"
swingLength  = input.int(8, "Swing High/Low Length", minval = 1, maxval = 50, group = grpS, tooltip = "Bars required on each side of a pivot. Higher = fewer but more significant swings. Swings confirm this many bars late and then never repaint.")
showZig      = input.bool(true, "Show zig-zag of swings", group = grpS)
showLabels   = input.bool(true, "Show swing labels (HH / HL / LH / LL)", group = grpS)
showBos      = input.bool(true, "Show Break of Structure (BOS)", group = grpS)

grpZ         = "Supply and Demand Zones"
showZones    = input.bool(true, "Show supply / demand zones", group = grpZ)
zonesToKeep  = input.int(10, "Zones to keep per side", minval = 1, maxval = 50, group = grpZ, tooltip = "Only the newest N supply and N demand zones are drawn, to stay within the 500 drawing-object limit.")
useAtrFloor  = input.bool(true, "Give thin zones a minimum thickness", group = grpZ)
atrMultFloor = input.float(0.5, "Minimum thickness (x ATR)", minval = 0.0, step = 0.1, group = grpZ)
mitigation   = input.string("Remove", "When a zone is broken", options = ["Remove", "Grey out"], group = grpZ)
extendRight  = input.bool(true, "Extend active zones to the right", group = grpZ)

grpC         = "Colors"
supplyCol    = input.color(color.new(#e53935, 80), "Supply zone fill", group = grpC, inline = "1")
supplyLn     = input.color(color.new(#e53935, 35), "Border", group = grpC, inline = "1")
demandCol    = input.color(color.new(#26a69a, 80), "Demand zone fill", group = grpC, inline = "2")
demandLn     = input.color(color.new(#26a69a, 35), "Border", group = grpC, inline = "2")
brokenCol    = input.color(color.new(color.gray, 85), "Broken zone fill", group = grpC)
zzCol        = input.color(color.new(color.gray, 0), "Zig-zag line", group = grpC)
bullCol      = input.color(#26a69a, "Bullish structure", group = grpC)
bearCol      = input.color(#e53935, "Bearish structure", group = grpC)

grpD         = "Dashboard"
showTable    = input.bool(true, "Show dashboard", group = grpD)

// ---------------------------------------------------------------------------
// 2. SWING (PIVOT) DETECTION  -- hoisted to global scope, runs every bar
// ---------------------------------------------------------------------------
atr   = ta.atr(14)
phRaw = ta.pivothigh(high, swingLength, swingLength)
plRaw = ta.pivotlow(low, swingLength, swingLength)
isPH  = not na(phRaw)
isPL  = not na(plRaw)
minH  = atr * atrMultFloor

// ---------------------------------------------------------------------------
// 3. STATE
// ---------------------------------------------------------------------------
var float  lastPH      = na
var float  lastPL      = na
var float  bosHighLvl  = na
var float  bosLowLvl   = na
var bool   bosHighDone = true
var bool   bosLowDone  = true
var float  zzPrice     = na
var int    zzBar       = na
var string lastBos     = "-"

var box[]  supBox = array.new_box()
var bool[] supBrk = array.new_bool()
var box[]  demBox = array.new_box()
var bool[] demBrk = array.new_bool()

// ---------------------------------------------------------------------------
// 4. ZIG-ZAG  (connect each confirmed pivot to the previous one)
// ---------------------------------------------------------------------------
if isPH or isPL
    pPrice = isPH ? phRaw : plRaw
    pBar   = bar_index - swingLength
    if showZig and not na(zzBar) and pBar != zzBar
        line.new(zzBar, zzPrice, pBar, pPrice, color = zzCol, width = 1)
    zzPrice := pPrice
    zzBar   := pBar

// ---------------------------------------------------------------------------
// 5. SWING HIGH  ->  structure label, BOS level, supply zone
// ---------------------------------------------------------------------------
if isPH
    pivotBar = bar_index - swingLength
    txt = na(lastPH) ? "H" : (phRaw > lastPH ? "HH" : "LH")
    col = na(lastPH) ? color.gray : (phRaw > lastPH ? bullCol : bearCol)
    if showLabels
        label.new(pivotBar, phRaw, txt, style = label.style_label_down, color = color.new(col, 20), textcolor = color.white, size = size.tiny)
    if showZones
        top = phRaw
        bot = math.max(open[swingLength], close[swingLength])
        if useAtrFloor and (top - bot) < minH
            bot := top - minH
        b = box.new(pivotBar, top, bar_index, bot, border_color = supplyLn, bgcolor = supplyCol, border_width = 1)
        array.push(supBox, b)
        array.push(supBrk, false)
        if array.size(supBox) > zonesToKeep
            box.delete(array.shift(supBox))
            array.shift(supBrk)
    bosHighLvl  := phRaw
    bosHighDone := false
    lastPH      := phRaw

// ---------------------------------------------------------------------------
// 6. SWING LOW  ->  structure label, BOS level, demand zone
// ---------------------------------------------------------------------------
if isPL
    pivotBar = bar_index - swingLength
    txt = na(lastPL) ? "L" : (plRaw < lastPL ? "LL" : "HL")
    col = na(lastPL) ? color.gray : (plRaw < lastPL ? bearCol : bullCol)
    if showLabels
        label.new(pivotBar, plRaw, txt, style = label.style_label_up, color = color.new(col, 20), textcolor = color.white, size = size.tiny)
    if showZones
        bot = plRaw
        top = math.min(open[swingLength], close[swingLength])
        if useAtrFloor and (top - bot) < minH
            top := bot + minH
        b = box.new(pivotBar, top, bar_index, bot, border_color = demandLn, bgcolor = demandCol, border_width = 1)
        array.push(demBox, b)
        array.push(demBrk, false)
        if array.size(demBox) > zonesToKeep
            box.delete(array.shift(demBox))
            array.shift(demBrk)
    bosLowLvl  := plRaw
    bosLowDone := false
    lastPL     := plRaw

// ---------------------------------------------------------------------------
// 7. BREAK OF STRUCTURE  (first close beyond the most recent confirmed swing)
// ---------------------------------------------------------------------------
bullBos = not na(bosHighLvl) and not bosHighDone and close > bosHighLvl
bearBos = not na(bosLowLvl)  and not bosLowDone  and close < bosLowLvl
if bullBos
    bosHighDone := true
    lastBos := "Bullish"
    if showBos
        label.new(bar_index, bosHighLvl, "BOS", style = label.style_label_down, color = color.new(bullCol, 10), textcolor = color.white, size = size.tiny)
if bearBos
    bosLowDone := true
    lastBos := "Bearish"
    if showBos
        label.new(bar_index, bosLowLvl, "BOS", style = label.style_label_up, color = color.new(bearCol, 10), textcolor = color.white, size = size.tiny)

// ---------------------------------------------------------------------------
// 8. ZONE MAINTENANCE  (extend active zones, flag mitigation)
// ---------------------------------------------------------------------------
if array.size(supBox) > 0
    for i = array.size(supBox) - 1 to 0
        b = array.get(supBox, i)
        if not array.get(supBrk, i)
            if close > box.get_top(b)
                if mitigation == "Remove"
                    box.delete(b)
                    array.remove(supBox, i)
                    array.remove(supBrk, i)
                else
                    box.set_bgcolor(b, brokenCol)
                    box.set_border_color(b, brokenCol)
                    box.set_right(b, bar_index)
                    array.set(supBrk, i, true)
            else if extendRight
                box.set_right(b, bar_index)

if array.size(demBox) > 0
    for i = array.size(demBox) - 1 to 0
        b = array.get(demBox, i)
        if not array.get(demBrk, i)
            if close < box.get_bottom(b)
                if mitigation == "Remove"
                    box.delete(b)
                    array.remove(demBox, i)
                    array.remove(demBrk, i)
                else
                    box.set_bgcolor(b, brokenCol)
                    box.set_border_color(b, brokenCol)
                    box.set_right(b, bar_index)
                    array.set(demBrk, i, true)
            else if extendRight
                box.set_right(b, bar_index)

// ---------------------------------------------------------------------------
// 9. DASHBOARD
// ---------------------------------------------------------------------------
var table t = table.new(position.top_right, 2, 5, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
if showTable and barstate.islast
    bg = color.new(#1e222d, 0)
    table.cell(t, 0, 0, "S/D + Structure", text_color = color.white,  bgcolor = bg, text_size = size.small)
    table.cell(t, 1, 0, "",                text_color = color.white,  bgcolor = bg, text_size = size.small)
    table.cell(t, 0, 1, "Swing length",    text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(t, 1, 1, str.tostring(swingLength),         text_color = color.white, bgcolor = bg, text_size = size.small)
    table.cell(t, 0, 2, "Supply zones",    text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(array.size(supBox)),  text_color = bearCol,     bgcolor = bg, text_size = size.small)
    table.cell(t, 0, 3, "Demand zones",    text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(t, 1, 3, str.tostring(array.size(demBox)),  text_color = bullCol,     bgcolor = bg, text_size = size.small)
    table.cell(t, 0, 4, "Last BOS",        text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(t, 1, 4, lastBos, text_color = lastBos == "Bullish" ? bullCol : lastBos == "Bearish" ? bearCol : color.gray, bgcolor = bg, text_size = size.small)

// ---------------------------------------------------------------------------
// 10. ALERTS
// ---------------------------------------------------------------------------
alertcondition(bullBos, "Bullish BOS", "Bullish Break of Structure")
alertcondition(bearBos, "Bearish BOS", "Bearish Break of Structure")
alertcondition(isPH and showZones, "New supply zone", "New supply zone formed")
alertcondition(isPL and showZones, "New demand zone", "New demand zone formed")
````

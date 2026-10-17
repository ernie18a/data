# Auto Support and Resistance [3Commas]

- url: https://www.tradingview.com/script/fyYzF187-Auto-Support-and-Resistance-3Commas/
- type: indicator
- pine_id: PUB;ba06aacc379c4ae9a12e8be1f41b8dff
- version: 1.0

## Description

Auto Support and Resistance [3Commas]

This indicator maps market structure automatically. Instead of drawing levels by hand, it derives them from recent price action and volatility, then presents a single, consistent read of where price is trading, the zones around it, and the two most likely paths from here.

How it works (the method):

- Macro ceiling & floor — the highest high and lowest low over a configurable lookback window define the outer boundary of the current regime (Macro Resistance / Macro Support).

- Local decision levels — the indicator tracks confirmed swing pivots (a high or low with a set number of bars on each side) and selects the nearest significant pivot above and below price, ignoring any that hug the current price so the levels stay meaningful. These become the Local High / Decision and Local Low. Equilibrium marks the current price.

- Volatility-scaled zones — the Resistance, Support and Accumulation zones are sized from Average True Range (ATR), so they widen on volatile symbols and tighten on calm ones, staying meaningful across different assets and timeframes.

- Two scenario paths — from equilibrium the script projects a bullish and a bearish path as multi-leg zig-zags scaled to ATR, each ending at a target. You choose what the targets represent: an ATR-based measured move (default), the nearest local levels, or the macro boundary. Measured-move targets are capped to the macro range so they always stay on the chart.

How to use it:

1. Add it to any chart and timeframe. Levels, zones and paths populate automatically.
2. Tune detection in Settings: "Macro lookback" sets how far back the ceiling/floor is measured; "Swing sensitivity" controls how strong a pivot must be to count; "Min level distance", "Zone width" and "Scenario swing size" refine spacing; "Scenario target" picks what the arrows aim at.
3. Read it as a decision map: is price nearer the ceiling or the floor, which local level must break first, and which scenario path is in play.

Optional manual mode: turn "Auto-detect" off to enter your own levels, zones and targets — useful for presenting a pre-planned idea.

Colors: red = resistance/ceiling, blue = equilibrium/current price, green = support/floor. White = projected scenario paths.

This tool is for chart visualisation and educational purposes only and is not financial advice. It does not generate buy/sell signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 3Commas

//@version=6
// ─────────────────────────────────────────────────────────────
// Auto Support and Resistance [3Commas] — v3 (open-source)
// Auto-detects structure from price action, with optional manual override.
//
//   • Levels  : macro ceiling/floor from an N-bar range; local decision
//               levels from the nearest confirmed swing pivots to price.
//   • Zones   : supply / demand / accumulation bands sized by ATR volatility.
//   • Paths   : two ATR-scaled scenario projections (bull & bear) from the
//               current price toward the detected macro targets.
//
// Turn "Auto-detect" OFF to type your own values (v1 behaviour).
// Colors: red = resistance/ceiling, blue = equilibrium/current, green = support/floor.
// ─────────────────────────────────────────────────────────────
indicator("Auto Support and Resistance [3Commas]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ══════════ MODE ══════════
gMode = "Mode"
autoMode = input.bool(true, "Auto-detect levels from price action", group=gMode, tooltip="ON: levels, zones and scenario paths are computed from swing pivots and ATR volatility. OFF: use the manual values below (v1 behaviour).")

// ══════════ AUTO-DETECTION ══════════
gDet = "Auto-detection"
lookback = input.int(120, "Macro lookback (bars)",            minval=20, group=gDet, tooltip="Window used for the macro ceiling/floor (highest high / lowest low).")
pivLen   = input.int(15,  "Swing sensitivity (pivot bars)",   minval=2,  group=gDet, tooltip="Bars on each side required to confirm a swing pivot. Higher = fewer, stronger levels.")
atrLen   = input.int(14,  "Volatility length (ATR)",          minval=1,  group=gDet)
zoneMult = input.float(0.6, "Zone width (x ATR)",             minval=0.1, step=0.1, group=gDet)
minGapMult = input.float(0.75, "Min level distance (x ATR)",  minval=0.0, step=0.1, group=gDet, tooltip="Local levels ignore swing pivots closer to price than this, so labels don't crowd the current price.")
tgtMode = input.string("ATR projection", "Scenario target", options=["ATR projection", "Local levels", "Macro levels"], group=gDet, tooltip="What the bull/bear scenario arrows aim at. ATR projection = a measured move from price; Local = nearest swing levels; Macro = outer range boundary.")
tgtAtr  = input.float(4.0, "ATR projection distance (x ATR)", minval=0.5, step=0.5, group=gDet, tooltip="Used when Scenario target = ATR projection.")
swingMult = input.float(2.5, "Scenario swing size (x ATR)",   minval=0.5, step=0.1, group=gDet, tooltip="Amplitude of the projected zig-zag legs.")

// ══════════ MANUAL OVERRIDE (used only when Auto-detect is OFF) ══════════
gL = "Manual · Horizontal levels"
macroResIn  = input.float(0.30,  "Macro Resistance",      group=gL)
localHighIn = input.float(0.24,  "Local High / Decision", group=gL)
equilibIn   = input.float(0.20,  "Equilibrium (current)", group=gL)
localLowIn  = input.float(0.175, "Local Low",             group=gL)
macroSupIn  = input.float(0.145, "Macro Support",         group=gL)

gZ = "Manual · Zones (top / bottom)"
resZoneTopIn = input.float(0.26,  "Resistance top",    group=gZ)
resZoneBotIn = input.float(0.235, "Resistance bottom", group=gZ)
supZoneTopIn = input.float(0.18,  "Support top",       group=gZ)
supZoneBotIn = input.float(0.175, "Support bottom",    group=gZ)
accZoneTopIn = input.float(0.155, "Accum top",         group=gZ)
accZoneBotIn = input.float(0.145, "Accum bottom",      group=gZ)

gB = "Manual · Bullish arrow"
b1In      = input.float(0.2425, "Bull leg 1", group=gB)
b2In      = input.float(0.215,  "Bull leg 2", group=gB)
b3In      = input.float(0.245,  "Bull leg 3", group=gB)
bullTgtIn = input.float(0.30,   "Bull target", group=gB)

gS = "Manual · Bearish arrow"
s1In      = input.float(0.175, "Bear leg 1", group=gS)
s2In      = input.float(0.192, "Bear leg 2", group=gS)
s3In      = input.float(0.17,  "Bear leg 3", group=gS)
bearTgtIn = input.float(0.145, "Bear target", group=gS)

// ══════════ GEOMETRY ══════════
gG = "Geometry"
legBars = input.int(5,  "Bars per arrow leg",       group=gG)
arrSpread = input.float(1.2, "Arrow spread (x ATR/bar)", minval=0.2, step=0.1, group=gG, tooltip="Scales the horizontal length of the final leg to the size of the move, so far targets lean out instead of going vertical.")
lblOff  = input.int(12, "Label push-right (bars)",  group=gG)
autoGap = input.bool(true, "Auto-scale label gap to price", group=gG)
lblGapIn = input.float(0.007, "Manual label gap",   group=gG, tooltip="Used only when auto-scale is OFF.")

// ══════════════════ AUTO-DETECTION ENGINE ══════════════════
atr = ta.atr(atrLen)

// Macro ceiling / floor over the lookback window
macroResAuto = ta.highest(high, lookback)
macroSupAuto = ta.lowest(low,  lookback)

// Rolling store of confirmed swing pivots
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)
var array<float> phArr = array.new_float()
var array<float> plArr = array.new_float()
if not na(ph)
    array.push(phArr, ph)
    if array.size(phArr) > 60
        array.shift(phArr)
if not na(pl)
    array.push(plArr, pl)
    if array.size(plArr) > 60
        array.shift(plArr)

// Minimum distance a local level must sit from price (keeps labels from crowding)
minGap = ta.atr(atrLen) * minGapMult

// Nearest pivot high ABOVE price (beyond the min-gap) -> local decision level
float nearResUp = na
if array.size(phArr) > 0
    for i = 0 to array.size(phArr) - 1
        v = array.get(phArr, i)
        if v > close + minGap and (na(nearResUp) or v < nearResUp)
            nearResUp := v
// Nearest pivot low BELOW price (beyond the min-gap) -> local support level
float nearSupDn = na
if array.size(plArr) > 0
    for i = 0 to array.size(plArr) - 1
        v = array.get(plArr, i)
        if v < close - minGap and (na(nearSupDn) or v > nearSupDn)
            nearSupDn := v

// ── Resolve final levels (auto vs manual) ──
macroRes  = autoMode ? macroResAuto : macroResIn
localHigh = autoMode ? (na(nearResUp) ? macroResAuto : nearResUp) : localHighIn
equilib   = autoMode ? close : equilibIn
localLow  = autoMode ? (na(nearSupDn) ? macroSupAuto : nearSupDn) : localLowIn
macroSup  = autoMode ? macroSupAuto : macroSupIn

// ── Zones ──
z = atr * zoneMult
resZoneTop = autoMode ? macroRes + z : resZoneTopIn
resZoneBot = autoMode ? macroRes - z : resZoneBotIn
supZoneTop = autoMode ? macroSup + z : supZoneTopIn
supZoneBot = autoMode ? macroSup - z : supZoneBotIn
accZoneTop = autoMode ? localLow     : accZoneTopIn
accZoneBot = autoMode ? macroSup     : accZoneBotIn

// ── Scenario paths (ATR-scaled zig-zag, always alternating) ──
sw = atr * swingMult
// ATR projection is clamped to the macro range so a target never lands off-screen
bullTgtAuto = tgtMode == "Local levels" ? localHigh : tgtMode == "Macro levels" ? macroRes : math.min(equilib + atr * tgtAtr, macroRes)
bearTgtAuto = tgtMode == "Local levels" ? localLow  : tgtMode == "Macro levels" ? macroSup : math.max(equilib - atr * tgtAtr, macroSup)
bullTgt = autoMode ? bullTgtAuto      : bullTgtIn
bearTgt = autoMode ? bearTgtAuto      : bearTgtIn
// Intermediate legs clamped inside the target band so they never overshoot the pane
b1      = autoMode ? equilib - z                              : b1In
b2      = autoMode ? math.min(equilib + sw, bullTgt - z*0.3)  : b2In
b3      = autoMode ? equilib + z                              : b3In
s1p     = autoMode ? equilib + z                              : s1In
s2p     = autoMode ? math.max(equilib - sw, bearTgt + z*0.3)  : s2In
s3p     = autoMode ? equilib - z                              : s3In

// ── Label vertical gap: auto-scales to price (fixes per-coin tuning) ──
lblGap = autoGap ? math.max(atr * 0.5, close * 0.01) : lblGapIn

// ══════════════════ RENDER ══════════════════
var array<line>  Ls = array.new_line()
var array<label> Bs = array.new_label()
var array<box>   Xs = array.new_box()

fmt(float v) => str.tostring(v, format.mintick)

if barstate.islast
    // clear previous frame (prevents duplicates on realtime ticks)
    if array.size(Ls) > 0
        for i = 0 to array.size(Ls) - 1
            line.delete(array.get(Ls, i))
    if array.size(Bs) > 0
        for i = 0 to array.size(Bs) - 1
            label.delete(array.get(Bs, i))
    if array.size(Xs) > 0
        for i = 0 to array.size(Xs) - 1
            box.delete(array.get(Xs, i))
    array.clear(Ls)
    array.clear(Bs)
    array.clear(Xs)

    p     = bar_index
    left  = p - lookback
    right = p

    // Zones
    array.push(Xs, box.new(left, resZoneTop, right, resZoneBot, border_color=color.new(color.red,   80), bgcolor=color.new(color.red,   88)))
    array.push(Xs, box.new(left, supZoneTop, right, supZoneBot, border_color=color.new(color.green, 80), bgcolor=color.new(color.green, 88)))
    array.push(Xs, box.new(left, accZoneTop, right, accZoneBot, border_color=color.new(color.green, 85), bgcolor=color.new(color.green, 92)))

    // Horizontal levels
    array.push(Ls, line.new(left, macroRes,  right, macroRes,  color=color.red,   width=2, style=line.style_solid))
    array.push(Ls, line.new(left, localHigh, right, localHigh, color=color.red,   width=1, style=line.style_dashed))
    array.push(Ls, line.new(left, equilib,   right, equilib,   color=color.blue,  width=1, style=line.style_dotted))
    array.push(Ls, line.new(left, localLow,  right, localLow,  color=color.green, width=1, style=line.style_dashed))
    array.push(Ls, line.new(left, macroSup,  right, macroSup,  color=color.green, width=2, style=line.style_solid))

    // Right-edge labels
    array.push(Bs, label.new(p+lblOff, macroRes,  "Macro Resistance $"      + fmt(macroRes),  xloc=xloc.bar_index, yloc=yloc.price, color=color.red,   textcolor=color.white, style=label.style_label_left, size=size.small))
    array.push(Bs, label.new(p+lblOff, localHigh, "Local High / Decision $" + fmt(localHigh), xloc=xloc.bar_index, yloc=yloc.price, color=color.red,   textcolor=color.white, style=label.style_label_left, size=size.small))
    array.push(Bs, label.new(p+lblOff, equilib,   "Equilibrium (current) $" + fmt(equilib),   xloc=xloc.bar_index, yloc=yloc.price, color=color.blue,  textcolor=color.white, style=label.style_label_left, size=size.small))
    array.push(Bs, label.new(p+lblOff, localLow,  "Local Low $"             + fmt(localLow),  xloc=xloc.bar_index, yloc=yloc.price, color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small))
    array.push(Bs, label.new(p+lblOff, macroSup,  "Macro Support $"         + fmt(macroSup),  xloc=xloc.bar_index, yloc=yloc.price, color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small))

    // Final-leg horizontal length scales with the size of the move (far targets lean, not vertical)
    atrSafe = math.max(atr, syminfo.mintick)
    maxFinalBars = 22
    bullFinalBars = math.min(maxFinalBars, math.max(legBars, int(math.round(math.abs(bullTgt - equilib) / atrSafe * arrSpread))))
    bearFinalBars = math.min(maxFinalBars, math.max(legBars, int(math.round(math.abs(bearTgt - equilib) / atrSafe * arrSpread))))
    bx3 = p + legBars*3
    bxT = bx3 + bullFinalBars + 2
    sxT = bx3 + bearFinalBars + 2

    // Bullish scenario path (arrowhead on final leg)
    array.push(Ls, line.new(p,           equilib, p+legBars,   b1,      color=color.white, width=2))
    array.push(Ls, line.new(p+legBars,   b1,      p+legBars*2, b2,      color=color.white, width=2))
    array.push(Ls, line.new(p+legBars*2, b2,      bx3,         b3,      color=color.white, width=2))
    array.push(Ls, line.new(bx3,         b3,      bxT,         bullTgt, color=color.white, width=2, style=line.style_arrow_right))
    array.push(Bs, label.new(bxT, bullTgt+lblGap, "Bull target $" + fmt(bullTgt), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(color.green, 15), textcolor=color.white, size=size.small))

    // Bearish scenario path (arrowhead on final leg)
    array.push(Ls, line.new(p,           equilib, p+legBars,   s1p,     color=color.white, width=2))
    array.push(Ls, line.new(p+legBars,   s1p,     p+legBars*2, s2p,     color=color.white, width=2))
    array.push(Ls, line.new(p+legBars*2, s2p,     bx3,         s3p,     color=color.white, width=2))
    array.push(Ls, line.new(bx3,         s3p,     sxT,         bearTgt, color=color.white, width=2, style=line.style_arrow_right))
    array.push(Bs, label.new(sxT, bearTgt-lblGap, "Bear target $" + fmt(bearTgt), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_upper_right, color=color.new(color.red, 15), textcolor=color.white, size=size.small))
````

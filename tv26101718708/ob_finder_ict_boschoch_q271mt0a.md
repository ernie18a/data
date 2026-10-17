# OB Finder ICT  BOS/CHoCH

- url: https://www.tradingview.com/script/q271mT0a-OB-Finder-ICT-BOS-CHoCH/
- type: indicator
- pine_id: PUB;496b9a3a4db54b5a925beac062d83f10
- version: 1.0

## Description

The wugamlo code is Pine Script v4 and about 80 lines. The best approach is to port it to v5 and add each of the above as optional toggleable layers, so the user can run it clean or with the full ICT order flow stack. The structure would be:

Base: wugamlo OB detection logic (ported to v5)
Layer 1: Displacement strength score on each OB zone
Layer 2: BOS / CHoCH labels on structural breaks
Layer 3: Liquidity sweep flag (inducement) before OB formation
Layer 4: FVG linkage highlight (gold border = OB + FVG confluence)
Layer 5: Mitigation tracking (zones close off when hit)
Layer 6: Relative volume confirmation marker

## Source Code

````pine
//@version=5
// ══════════════════════════════════════════════════════════════════════════════
//  Order Block Finder + BOS / CHoCH + ICT Order Flow
//  Based on "Order Block Finder (Experimental)" by wugamlo — ported to v5
//  Extended with: Break of Structure, Change of Character, Displacement,
//  FVG markers, and swing point visualisation
// ══════════════════════════════════════════════════════════════════════════════
indicator("OB Finder + BOS/CHoCH | wugamlo × ICT",
     overlay=true, max_boxes_count=200, max_lines_count=400, max_labels_count=400)


// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — ORDER BLOCKS
// ══════════════════════════════════════════════════════════════════════════════
obPeriods   = input.int   (7,       "Sequential Candles to Confirm OB", minval=1, maxval=20, group="Order Blocks")
obThreshold = input.float (0.0,     "Min % Move for Valid OB",          minval=0, step=0.1,  group="Order Blocks")
bullOBCount = input.int   (3,       "Max Bullish OBs to Show",          minval=1, maxval=10, group="Order Blocks")
bearOBCount = input.int   (3,       "Max Bearish OBs to Show",          minval=1, maxval=10, group="Order Blocks")
showOBMidline = input.bool(true,    "Show OB Midline",                              group="Order Blocks")
colorScheme = input.string("LIGHT", "Color Scheme", options=["LIGHT","DARK"],       group="Order Blocks")


// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — MARKET STRUCTURE
// ══════════════════════════════════════════════════════════════════════════════
swLen        = input.int (5,    "Swing Length (pivots)",  minval=2, maxval=50,  group="Market Structure")
showBOS      = input.bool(true, "Show BOS",                                     group="Market Structure")
showChoCH    = input.bool(true, "Show CHoCH",                                   group="Market Structure")
showStrLines = input.bool(true, "Show Structure Lines",                         group="Market Structure")
showSwDots   = input.bool(false,"Show Swing High/Low Dots",                     group="Market Structure")


// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — ICT ORDER FLOW
// ══════════════════════════════════════════════════════════════════════════════
showDisp     = input.bool(true,  "Highlight Displacement Candles",              group="ICT Order Flow",
     tooltip="Large-bodied candles (body ≥ threshold) that signal institutional momentum.")
dispThresh   = input.float(70.0, "Displacement Body %",      minval=30, maxval=99, step=5, group="ICT Order Flow",
     tooltip="Minimum body-to-range % for a candle to qualify as displacement.")
showFVG      = input.bool(true,  "Show Fair Value Gaps (FVG)",                  group="ICT Order Flow")
showInducement = input.bool(true,"Show Inducement Sweeps",                      group="ICT Order Flow",
     tooltip="Marks when price wicks just beyond a swing point then reverses — a classic liquidity grab.")


// ══════════════════════════════════════════════════════════════════════════════
//  COLORS
// ══════════════════════════════════════════════════════════════════════════════
bullC    = colorScheme == "DARK" ? color.white           : color.new(#26A69A, 0)
bearC    = colorScheme == "DARK" ? color.new(#42A5F5, 0) : color.new(#EF5350, 0)
bosUpC   = input.color(color.new(#00BCD4, 0),  "BOS ▲ Color",     group="Colors")
bosDnC   = input.color(color.new(#EF5350, 0),  "BOS ▼ Color",     group="Colors")
chUpC    = input.color(color.new(#FF9800, 0),  "CHoCH ▲ Color",   group="Colors")
chDnC    = input.color(color.new(#9C27B0, 0),  "CHoCH ▼ Color",   group="Colors")
dispUpC  = input.color(color.new(#00E676, 60), "Displacement ▲",  group="Colors")
dispDnC  = input.color(color.new(#FF1744, 60), "Displacement ▼",  group="Colors")
fvgBullC = input.color(color.new(#26C6DA, 88), "FVG Bullish",     group="Colors")
fvgBearC = input.color(color.new(#EF5350, 88), "FVG Bearish",     group="Colors")


// ══════════════════════════════════════════════════════════════════════════════
//  ORDER BLOCK DETECTION   (wugamlo logic — ported to Pine v5)
//  Bullish OB  = last bearish candle before N consecutive bullish candles
//  Bearish OB  = last bullish candle before N consecutive bearish candles
// ══════════════════════════════════════════════════════════════════════════════
ob_period = obPeriods + 1
absmove   = math.abs(close[ob_period] - close[1]) / close[ob_period] * 100
relmove   = absmove >= obThreshold

int upCount = 0
for i = 1 to obPeriods
    upCount += close[i] > open[i] ? 1 : 0
OB_bull = close[ob_period] < open[ob_period] and upCount == obPeriods and relmove

int dnCount = 0
for i = 1 to obPeriods
    dnCount += close[i] < open[i] ? 1 : 0
OB_bear = close[ob_period] > open[ob_period] and dnCount == obPeriods and relmove

// Storage for active OB boxes
var array<box>   bullBoxes  = array.new<box>()
var array<float> bullTop    = array.new_float()
var array<float> bullBot    = array.new_float()
var array<bool>  bullMit    = array.new_bool()

var array<box>   bearBoxes  = array.new<box>()
var array<float> bearTop    = array.new_float()
var array<float> bearBot    = array.new_float()
var array<bool>  bearMit    = array.new_bool()

// Draw new bullish OB
if OB_bull
    t = high[ob_period]
    b = low[ob_period]
    bx = box.new(bar_index - ob_period, t, bar_index, b,
         bgcolor=color.new(bullC, 78), border_color=bullC, border_width=1,
         extend=extend.right,
         text="Bull OB", text_size=size.tiny,
         text_color=color.new(bullC, 20), text_halign=text.align_left, text_valign=text.align_top)
    array.push(bullBoxes, bx)
    array.push(bullTop,   t)
    array.push(bullBot,   b)
    array.push(bullMit,   false)
    if showOBMidline
        line.new(bar_index - ob_period, (t+b)/2, bar_index, (t+b)/2,
             color=color.new(bullC, 40), style=line.style_dotted, extend=extend.right)
    // Trim to display limit
    if array.size(bullBoxes) > bullOBCount
        box.delete(array.shift(bullBoxes))
        array.shift(bullTop)
        array.shift(bullBot)
        array.shift(bullMit)

// Draw new bearish OB
if OB_bear
    t = high[ob_period]
    b = low[ob_period]
    bx = box.new(bar_index - ob_period, t, bar_index, b,
         bgcolor=color.new(bearC, 78), border_color=bearC, border_width=1,
         extend=extend.right,
         text="Bear OB", text_size=size.tiny,
         text_color=color.new(bearC, 20), text_halign=text.align_left, text_valign=text.align_top)
    array.push(bearBoxes, bx)
    array.push(bearTop,   t)
    array.push(bearBot,   b)
    array.push(bearMit,   false)
    if showOBMidline
        line.new(bar_index - ob_period, (t+b)/2, bar_index, (t+b)/2,
             color=color.new(bearC, 40), style=line.style_dotted, extend=extend.right)
    if array.size(bearBoxes) > bearOBCount
        box.delete(array.shift(bearBoxes))
        array.shift(bearTop)
        array.shift(bearBot)
        array.shift(bearMit)

// Mitigate OBs when price closes through the midpoint (CE)
bullSz = array.size(bullBoxes)
if bullSz > 0
    for i = 0 to bullSz - 1
        if not array.get(bullMit, i)
            ce = (array.get(bullTop, i) + array.get(bullBot, i)) / 2
            if low <= ce
                array.set(bullMit, i, true)
                bx = array.get(bullBoxes, i)
                box.set_bgcolor(bx, color.new(color.gray, 90))
                box.set_border_color(bx, color.new(color.gray, 60))
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)

bearSz = array.size(bearBoxes)
if bearSz > 0
    for i = 0 to bearSz - 1
        if not array.get(bearMit, i)
            ce = (array.get(bearTop, i) + array.get(bearBot, i)) / 2
            if high >= ce
                array.set(bearMit, i, true)
                bx = array.get(bearBoxes, i)
                box.set_bgcolor(bx, color.new(color.gray, 90))
                box.set_border_color(bx, color.new(color.gray, 60))
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)


// ══════════════════════════════════════════════════════════════════════════════
//  MARKET STRUCTURE — BOS + CHoCH
//
//  Logic:
//   • BOS  = price breaks a swing level in the SAME direction as the trend
//             (confirms continuation)
//   • CHoCH = price breaks a swing level AGAINST the current trend
//             (signals potential reversal)
//
//  Swing highs/lows are detected via ta.pivothigh / ta.pivotlow.
//  A pivot is confirmed swLen bars AFTER it forms, so drawings are
//  offset back to the actual pivot bar.
// ══════════════════════════════════════════════════════════════════════════════
swHigh = ta.pivothigh(high, swLen, swLen)
swLow  = ta.pivotlow (low,  swLen, swLen)

var float lastSH    = na   // most recent unbroken swing high
var int   lastSHBar = na   // its bar index
var float lastSL    = na   // most recent unbroken swing low
var int   lastSLBar = na
var int   trend     = 0    // 1 = bullish structure, -1 = bearish, 0 = neutral

// Update swing references as new pivots are confirmed
if not na(swHigh)
    lastSH    := swHigh
    lastSHBar := bar_index - swLen

if not na(swLow)
    lastSL    := swLow
    lastSLBar := bar_index - swLen

// Detect first bar to close through each level
breakUp   = not na(lastSH) and close > lastSH
breakDown = not na(lastSL) and close < lastSL

// Classify BEFORE updating trend
isBosUp   = breakUp   and (trend == 1 or trend == 0)
isBosDown = breakDown and (trend == -1 or trend == 0)
isChochUp = breakUp   and trend == -1
isChochDn = breakDown and trend == 1

// Update trend
if breakUp
    trend := 1
if breakDown
    trend := -1

// ── Draw BOS / CHoCH ────────────────────────────────────────────────────────
if breakUp
    c   = isChochUp ? chUpC : bosUpC
    lbl = isChochUp ? "CHoCH" : "BOS"
    if showStrLines and not na(lastSHBar)
        line.new(lastSHBar, lastSH, bar_index, lastSH,
             color=c, width=1, style=line.style_dashed)
    if (isBosUp and showBOS) or (isChochUp and showChoCH)
        label.new(bar_index, lastSH, lbl,
             color=color.new(c, 100), textcolor=c,
             style=label.style_none, size=size.tiny)
    lastSH := na   // consumed — wait for new swing high

if breakDown
    c   = isChochDn ? chDnC : bosDnC
    lbl = isChochDn ? "CHoCH" : "BOS"
    if showStrLines and not na(lastSLBar)
        line.new(lastSLBar, lastSL, bar_index, lastSL,
             color=c, width=1, style=line.style_dashed)
    if (isBosDown and showBOS) or (isChochDn and showChoCH)
        label.new(bar_index, lastSL, lbl,
             color=color.new(c, 100), textcolor=c,
             style=label.style_none, size=size.tiny)
    lastSL := na

// Swing high/low dots (optional — plotted at actual pivot bar via offset)
plotshape(showSwDots and not na(swHigh), title="Swing High",
     location=location.abovebar, style=shape.triangledown,
     color=color.new(bearC, 20), size=size.tiny, offset=-swLen)
plotshape(showSwDots and not na(swLow),  title="Swing Low",
     location=location.belowbar, style=shape.triangleup,
     color=color.new(bullC, 20), size=size.tiny, offset=-swLen)


// ══════════════════════════════════════════════════════════════════════════════
//  ICT ORDER FLOW — DISPLACEMENT CANDLES
//
//  A displacement candle is an unusually large-bodied bar that represents
//  institutional commitment to a direction. Body must be ≥ dispThresh % of
//  the total high-to-low range. These often form or validate Order Blocks
//  and precede Market Structure Shifts.
// ══════════════════════════════════════════════════════════════════════════════
candleRange = high - low
candleBody  = math.abs(close - open)
bodyPct     = candleRange > 0 ? (candleBody / candleRange) * 100 : 0
isDisp      = bodyPct >= dispThresh

dispBull = showDisp and isDisp and close > open
dispBear = showDisp and isDisp and close < open

barcolor(dispBull ? dispUpC : dispBear ? dispDnC : na, title="Displacement Candle")


// ══════════════════════════════════════════════════════════════════════════════
//  ICT ORDER FLOW — FAIR VALUE GAPS (FVG)
//
//  Bullish FVG: high[2] < low[0]  — gap left below current bar
//  Bearish FVG: low[2]  > high[0] — gap left above current bar
//  Zones drawn with extend.right; mitigated at CE (midpoint).
// ══════════════════════════════════════════════════════════════════════════════
var array<box>   fvgBullBoxes = array.new<box>()
var array<float> fvgBullTop   = array.new_float()
var array<float> fvgBullBot   = array.new_float()
var array<bool>  fvgBullMit   = array.new_bool()

var array<box>   fvgBearBoxes = array.new<box>()
var array<float> fvgBearTop   = array.new_float()
var array<float> fvgBearBot   = array.new_float()
var array<bool>  fvgBearMit   = array.new_bool()

FVG_LIMIT = 10

if showFVG
    // New bullish FVG
    if high[2] < low[0]
        ft = low[0]
        fb = high[2]
        bx = box.new(bar_index - 1, ft, bar_index, fb,
             bgcolor=fvgBullC, border_color=color.new(#26C6DA, 50), border_width=1,
             extend=extend.right)
        array.push(fvgBullBoxes, bx)
        array.push(fvgBullTop,   ft)
        array.push(fvgBullBot,   fb)
        array.push(fvgBullMit,   false)
        if array.size(fvgBullBoxes) > FVG_LIMIT
            box.delete(array.shift(fvgBullBoxes))
            array.shift(fvgBullTop)
            array.shift(fvgBullBot)
            array.shift(fvgBullMit)

    // New bearish FVG
    if low[2] > high[0]
        ft = low[2]
        fb = high[0]
        bx = box.new(bar_index - 1, ft, bar_index, fb,
             bgcolor=fvgBearC, border_color=color.new(#EF5350, 50), border_width=1,
             extend=extend.right)
        array.push(fvgBearBoxes, bx)
        array.push(fvgBearTop,   ft)
        array.push(fvgBearBot,   fb)
        array.push(fvgBearMit,   false)
        if array.size(fvgBearBoxes) > FVG_LIMIT
            box.delete(array.shift(fvgBearBoxes))
            array.shift(fvgBearTop)
            array.shift(fvgBearBot)
            array.shift(fvgBearMit)

// Mitigate FVGs at CE
fvgBullSz = array.size(fvgBullBoxes)
if fvgBullSz > 0
    for i = 0 to fvgBullSz - 1
        if not array.get(fvgBullMit, i)
            ce = (array.get(fvgBullTop, i) + array.get(fvgBullBot, i)) / 2
            if low <= ce
                array.set(fvgBullMit, i, true)
                bx = array.get(fvgBullBoxes, i)
                box.set_bgcolor(bx, color.new(color.gray, 92))
                box.set_border_color(bx, color.new(color.gray, 70))
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)

fvgBearSz = array.size(fvgBearBoxes)
if fvgBearSz > 0
    for i = 0 to fvgBearSz - 1
        if not array.get(fvgBearMit, i)
            ce = (array.get(fvgBearTop, i) + array.get(fvgBearBot, i)) / 2
            if high >= ce
                array.set(fvgBearMit, i, true)
                bx = array.get(fvgBearBoxes, i)
                box.set_bgcolor(bx, color.new(color.gray, 92))
                box.set_border_color(bx, color.new(color.gray, 70))
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)


// ══════════════════════════════════════════════════════════════════════════════
//  ICT ORDER FLOW — INDUCEMENT (LIQUIDITY SWEEP)
//
//  A classic ICT inducement: price wicks beyond a recent swing high/low
//  but CLOSES back inside it on the same bar. This traps breakout traders
//  and signals a likely reversal in the opposite direction.
//  Marked with a small label above/below the wick.
// ══════════════════════════════════════════════════════════════════════════════
if showInducement
    // Bearish inducement: wick above swing high but close back below it
    if not na(lastSH) and high > lastSH and close < lastSH
        label.new(bar_index, high, "IDM", color=color.new(bearC, 20),
             textcolor=color.white, style=label.style_label_down, size=size.tiny)

    // Bullish inducement: wick below swing low but close back above it
    if not na(lastSL) and low < lastSL and close > lastSL
        label.new(bar_index, low, "IDM", color=color.new(bullC, 20),
             textcolor=color.white, style=label.style_label_up, size=size.tiny)


// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(OB_bull,    "Bullish OB Formed",  "Bullish Order Block detected")
alertcondition(OB_bear,    "Bearish OB Formed",  "Bearish Order Block detected")
alertcondition(isBosUp,    "BOS Bullish",        "Break of Structure — Bullish continuation")
alertcondition(isBosDown,  "BOS Bearish",        "Break of Structure — Bearish continuation")
alertcondition(isChochUp,  "CHoCH Bullish",      "Change of Character — Bullish reversal signal")
alertcondition(isChochDn,  "CHoCH Bearish",      "Change of Character — Bearish reversal signal")
alertcondition(dispBull,   "Bullish Displacement","Bullish displacement candle")
alertcondition(dispBear,   "Bearish Displacement","Bearish displacement candle")
````

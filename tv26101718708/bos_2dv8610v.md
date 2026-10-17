# BOS

- url: https://www.tradingview.com/script/2DV8610v-BOS/
- type: indicator
- pine_id: PUB;fc52218512ca47ed91e3f3ab6fe3b800
- version: 1.0

## Description

BOS custom indicator used to determine where the break of structure

## Source Code

````pine
//@version=6
indicator("BOS", shorttitle="BOS", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
var string GRP_BOS  = "BREAK OF STRUCTURE"
var string GRP_LINE = "LINE"
var string GRP_LBL  = "LABEL"
var string GRP_ADV  = "ADVANCED"

// ── Break of Structure ──────────────────────────────────────────────────────
markBOS      = input.bool(true,
     title   = "Mark BoS?",
     tooltip = "Enable/disable BOS markers on the chart.",
     group   = GRP_BOS)

bullBOSColor = input.color(#26a69a,
     title   = "Bullish Color",
     tooltip = "Color of the BOS label when price closes above the active high (bullish BOS).",
     group   = GRP_BOS,
     inline  = "bosColors")

bearBOSColor = input.color(#ef5350,
     title   = "Bearish Color",
     tooltip = "Color of the BOS label when price closes below the active low (bearish BOS).",
     group   = GRP_BOS,
     inline  = "bosColors")

// ── Line ───────────────────────────────────────────────────────────────────
confirmedStyle = input.string("Dashed",
     title   = "Confirmed swing line",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = "Style of the ACTIVE confirmed structure line (current range boundary). Blue = high, Orange = low.",
     group   = GRP_LINE,
     inline  = "confLine")

confirmedBullColor = input.color(#2962FF,
     title   = "Bullish",
     tooltip = "Color of the active confirmed structure HIGH line.",
     group   = GRP_LINE,
     inline  = "confLine")

confirmedBearColor = input.color(#FF6D00,
     title   = "Bearish",
     tooltip = "Color of the active confirmed structure LOW line.",
     group   = GRP_LINE,
     inline  = "confLine")

oldStyle = input.string("Solid",
     title   = "Old swing line",
     options = ["Solid", "Dashed", "Dotted"],
     tooltip = "Style of OLD (invalidated) structure lines. These lines STOP at the bar where price mitigated/closed through them — they do not extend forever.",
     group   = GRP_LINE,
     inline  = "oldLine")

oldBullColor = input.color(#ffffff,
     title   = "Bullish",
     tooltip = "Color of the old invalidated structure HIGH line.",
     group   = GRP_LINE,
     inline  = "oldLine")

oldBearColor = input.color(#000000,
     title   = "Bearish",
     tooltip = "Color of the old invalidated structure LOW line.",
     group   = GRP_LINE,
     inline  = "oldLine")

lineThickness = input.int(2,
     title   = "Thickness",
     minval  = 1, maxval = 5,
     tooltip = "Width of all structure lines (1–5).",
     group   = GRP_LINE)

// ── Label ──────────────────────────────────────────────────────────────────
showBreakCount = input.bool(true,
     title   = "Show break count?",
     tooltip = "Show a sequential number (1, 2, 3…) at each BOS event. Resets when direction flips.",
     group   = GRP_LBL)

maxBreakCount = input.int(20,
     title   = "Max. count",
     minval  = 1, maxval = 99,
     tooltip = "Maximum break count number to display. Default 20.",
     group   = GRP_LBL)

// ── Advanced ───────────────────────────────────────────────────────────────
keepOldLines = input.int(3,
     title   = "Keep last N old lines",
     minval  = 0, maxval = 10,
     tooltip = "How many old (broken) structure lines to keep visible. Each line stops exactly where price closed through it. Set 0 to remove immediately. Default 3.",
     group   = GRP_ADV)

showBOSLabel = input.bool(true,
     title   = "Show 'BOS' text label",
     tooltip = "Toggle the 'BOS' text callout at each break event.",
     group   = GRP_ADV)

labelSize = input.string("Small",
     title   = "BOS label size",
     options = ["Tiny", "Small", "Normal", "Large"],
     tooltip = "Size of the BOS text label.",
     group   = GRP_ADV)

showPendingLines = input.bool(false,
     title   = "Show pending (unconfirmed) lines",
     tooltip = "Draw a faint dotted line at unconfirmed candidate swing levels. Disappears once confirmed or invalidated.",
     group   = GRP_ADV)

alertOnBOS = input.bool(true,
     title   = "Enable BOS alerts",
     tooltip = "Master switch for Bullish BOS and Bearish BOS alert conditions.",
     group   = GRP_ADV)

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════
f_lineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_labelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

// ═══════════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════════

// ── Active confirmed range ───────────────────────────────────────────────────
var float activeHigh    = na
var float activeLow     = na
var int   activeHighBar = na
var int   activeLowBar  = na

// ── Candidate (unconfirmed) highs/lows ──────────────────────────────────────
var float candHigh     = na
var float candHighWick = na
var int   candHighBar  = na
var float candHighLo   = na   // low of candle that made the high (confirmation trigger)

var float candLow      = na
var float candLowWick  = na
var int   candLowBar   = na
var float candLowHi    = na   // high of candle that made the low (confirmation trigger)

// ── Break counters ────────────────────────────────────────────────────────────
var int bullCount = 0
var int bearCount = 0

// ── Old line storage: [line, level, isBull]
//    We store the line objects so we can later CLOSE them at mitigation bar
var line[]  oldLines      = array.new<line>(0)
var float[] oldLineLevels = array.new<float>(0)
var bool[]  oldLineBull   = array.new<bool>(0)

// ── Active (redrawn each bar) lines ─────────────────────────────────────────
var line actHighLine = na
var line actLowLine  = na

// ── Pending dotted lines ─────────────────────────────────────────────────────
var line pendHighLine = na
var line pendLowLine  = na

// ── Bootstrap ────────────────────────────────────────────────────────────────
var bool started = false

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: trim old line array to maxN (delete excess from front)
// ═══════════════════════════════════════════════════════════════════════════
f_trimOld(maxN) =>
    while array.size(oldLines) > maxN
        line.delete(array.shift(oldLines))
        array.shift(oldLineLevels)
        array.shift(oldLineBull)

// ═══════════════════════════════════════════════════════════════════════════
// MITIGATION CHECK — close old lines where price closed through them
// This runs EVERY bar to detect when price has mitigated an old level
// ═══════════════════════════════════════════════════════════════════════════
if array.size(oldLines) > 0
    int i = 0
    while i < array.size(oldLines)
        float lvl    = array.get(oldLineLevels, i)
        bool  isBull = array.get(oldLineBull,   i)
        line  ln     = array.get(oldLines,       i)

        // Mitigation: price body closes THROUGH the level
        // Bull old high → mitigated when close drops below it (from above)
        // Bear old low  → mitigated when close rises above it (from below)
        bool mitigated = false
        if isBull
            // Old high line: mitigated when close < level (price fell back through)
            mitigated := close < lvl and close[1] >= lvl
        else
            // Old low line: mitigated when close > level (price rose back through)
            mitigated := close > lvl and close[1] <= lvl

        if mitigated
            // End the line exactly at this bar
            line.set_x2(ln, bar_index)
            line.set_extend(ln, extend.none)
            // Remove from tracking arrays
            array.remove(oldLines,       i)
            array.remove(oldLineLevels,  i)
            array.remove(oldLineBull,    i)
            // Don't increment i — index shifted
        else
            i += 1

// ═══════════════════════════════════════════════════════════════════════════
// BAR LOGIC
// ═══════════════════════════════════════════════════════════════════════════

// ── Bootstrap: seed initial range from first 5 bars ─────────────────────────
if not started and bar_index >= 5
    float sHi = high, int sHiBar = bar_index
    float sLo = low,  int sLoBar = bar_index
    for k = 1 to 4
        if high[k] > sHi
            sHi := high[k], sHiBar := bar_index - k
        if low[k] < sLo
            sLo := low[k],  sLoBar := bar_index - k
    activeHigh := sHi, activeHighBar := sHiBar
    activeLow  := sLo, activeLowBar  := sLoBar
    started    := true

// ── Inside-bar guard ─────────────────────────────────────────────────────────
bool isInside = high <= high[1] and low >= low[1]

// ── Candidate detection (body close beyond prev candle high/low) ─────────────
bool newCandHigh = not isInside and close > high[1]
bool newCandLow  = not isInside and close < low[1]

if newCandHigh
    float bw = math.max(high, high[1])
    if na(candHigh) or bw > candHighWick
        candHigh     := close
        candHighWick := bw
        candHighBar  := bar_index
        candHighLo   := low

if newCandLow
    float bw = math.min(low, low[1])
    if na(candLow) or bw < candLowWick
        candLow      := close
        candLowWick  := bw
        candLowBar   := bar_index
        candLowHi    := high

// ── Confirmation (body close through candidate candle's opposite end) ─────────
bool highConf = not na(candHigh) and close < candHighLo and close[1] >= candHighLo
bool lowConf  = not na(candLow)  and close > candLowHi  and close[1] <= candLowHi

// ── BOS detection (body close through active range boundary) ──────────────────
bool bosBull = started and not na(activeHigh) and close > activeHigh and close[1] <= activeHigh
bool bosBear = started and not na(activeLow)  and close < activeLow  and close[1] >= activeLow

// ─── Resolve styles ──────────────────────────────────────────────────────────
_lsz  = f_labelSize(labelSize)
_conf = f_lineStyle(confirmedStyle)
_old  = f_lineStyle(oldStyle)

// ═══════════════════════════════════════════════════════════════════════════
// BOS EVENT HANDLERS
// ═══════════════════════════════════════════════════════════════════════════

// ── Bullish BOS ──────────────────────────────────────────────────────────────
if bosBull and markBOS
    // Draw old high line — starts at swing bar, extends right (will be closed at mitigation)
    if not na(activeHighBar) and not na(activeHigh)
        ln = line.new(activeHighBar, activeHigh, bar_index, activeHigh,
             color   = oldBullColor,
             style   = _old,
             width   = lineThickness,
             extend  = extend.right)
        array.push(oldLines,      ln)
        array.push(oldLineLevels, activeHigh)
        array.push(oldLineBull,   true)
        f_trimOld(keepOldLines)

    // BOS label above the break bar
    if showBOSLabel
        label.new(bar_index, high,
             text      = "BOS",
             color     = color.new(bullBOSColor, 20),
             textcolor = color.white,
             style     = label.style_label_down,
             size      = _lsz)

    // Break count label on the old high line level
    bullCount += 1
    bearCount  := 0
    if showBreakCount and bullCount <= maxBreakCount
        label.new(bar_index, activeHigh,
             text      = str.tostring(bullCount),
             color     = color.new(oldBullColor, 70),
             textcolor = oldBullColor,
             style     = label.style_label_down,
             size      = size.tiny)

    // Reset and await new confirmed high
    candHigh := na, candHighWick := na, candHighBar := na, candHighLo := na
    activeHigh := na, activeHighBar := na

// ── Bearish BOS ──────────────────────────────────────────────────────────────
if bosBear and markBOS
    if not na(activeLowBar) and not na(activeLow)
        ln = line.new(activeLowBar, activeLow, bar_index, activeLow,
             color   = oldBearColor,
             style   = _old,
             width   = lineThickness,
             extend  = extend.right)
        array.push(oldLines,      ln)
        array.push(oldLineLevels, activeLow)
        array.push(oldLineBull,   false)
        f_trimOld(keepOldLines)

    if showBOSLabel
        label.new(bar_index, low,
             text      = "BOS",
             color     = color.new(bearBOSColor, 20),
             textcolor = color.white,
             style     = label.style_label_up,
             size      = _lsz)

    bearCount += 1
    bullCount  := 0
    if showBreakCount and bearCount <= maxBreakCount
        label.new(bar_index, activeLow,
             text      = str.tostring(bearCount),
             color     = color.new(oldBearColor, 70),
             textcolor = oldBearColor,
             style     = label.style_label_up,
             size      = size.tiny)

    candLow := na, candLowWick := na, candLowBar := na, candLowHi := na
    activeLow := na, activeLowBar := na

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRMATION UPDATES
// ═══════════════════════════════════════════════════════════════════════════

if highConf
    activeHigh    := candHighWick
    activeHighBar := candHighBar
    candHigh := na, candHighWick := na, candHighBar := na, candHighLo := na

if lowConf
    activeLow    := candLowWick
    activeLowBar := candLowBar
    candLow := na, candLowWick := na, candLowBar := na, candLowHi := na

// ═══════════════════════════════════════════════════════════════════════════
// REDRAW ACTIVE (CONFIRMED) LINES — every bar
// ═══════════════════════════════════════════════════════════════════════════

if not na(actHighLine)
    line.delete(actHighLine)
    actHighLine := na
if not na(actLowLine)
    line.delete(actLowLine)
    actLowLine := na

if not na(activeHigh) and not na(activeHighBar)
    actHighLine := line.new(activeHighBar, activeHigh, bar_index, activeHigh,
         color  = confirmedBullColor,
         style  = _conf,
         width  = lineThickness,
         extend = extend.right)

if not na(activeLow) and not na(activeLowBar)
    actLowLine := line.new(activeLowBar, activeLow, bar_index, activeLow,
         color  = confirmedBearColor,
         style  = _conf,
         width  = lineThickness,
         extend = extend.right)

// ═══════════════════════════════════════════════════════════════════════════
// PENDING (UNCONFIRMED) LINES
// ═══════════════════════════════════════════════════════════════════════════

if not na(pendHighLine)
    line.delete(pendHighLine)
    pendHighLine := na
if not na(pendLowLine)
    line.delete(pendLowLine)
    pendLowLine := na

if showPendingLines
    if not na(candHighWick) and not na(candHighBar)
        pendHighLine := line.new(candHighBar, candHighWick, bar_index, candHighWick,
             color  = color.new(confirmedBullColor, 65),
             style  = line.style_dotted,
             width  = 1,
             extend = extend.right)
    if not na(candLowWick) and not na(candLowBar)
        pendLowLine := line.new(candLowBar, candLowWick, bar_index, candLowWick,
             color  = color.new(confirmedBearColor, 65),
             style  = line.style_dotted,
             width  = 1,
             extend = extend.right)

// ═══════════════════════════════════════════════════════════════════════════
// // ALERTS
// // ═══════════════════════════════════════════════════════════════════════════

// if alertOnBOS
//     alertcondition(bosBull, title="Bullish BOS",
//          message="BOS ▲  Price closed above active structure high — Bullish Break of Structure.")
//     alertcondition(bosBear, title="Bearish BOS",
//          message="BOS ▼  Price closed below active structure low — Bearish Break of Structure.")
````

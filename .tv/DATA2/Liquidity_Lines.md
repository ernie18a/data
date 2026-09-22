<!-- tradingview-pine-id: PUB;fe273d7adbd2441f9f7126d6258c32da -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Lines

Source: https://www.tradingview.com/script/H1HZVFXz-MSX-Liquidity-Lines/

## Description

Liquidity Lines

Marks resting liquidity at confirmed swing highs and lows, and shows you when it gets taken.

Every confirmed pivot high and pivot low gets a horizontal line that extends to the right and stays there until price trades through it. When a level is swept, the line dims and stops at the bar that took it — so at any moment the bright lines are the liquidity still sitting on the chart, and the faded ones are the history of what's already been run.

How the levels are placed

Three details that determine whether a level sits where orders actually rest:

Levels are drawn on the wick, not the close. Stops sit above the high and below the low, so that's where the line goes.

Each line starts at its own pivot bar. A pivot can only be confirmed some bars after it forms, and drawing the line from the confirmation bar misplaces it in time. This walks each line back to the swing it belongs to.

Equal highs and equal lows merge. A new pivot that forms within tolerance of a live level joins that level instead of drawing a second line a few ticks away, and the line thickens with each touch. A double or triple top reads as one heavy line rather than three thin ones stacked together — one pool of orders, drawn as one level, weighted by how many times price has left stops there.

Settings

Swing length — the main control. Higher values return fewer, more significant levels; lower values surface the minor intraday pools. 10 is a balanced default.

Merge tolerance — how close two pivots must be to count as the same pool, measured as a percentage of ATR so it scales across instruments and timeframes.

Break trigger — wick-through treats a level as taken the moment price trades past it; close-through only counts a body close beyond it.

Stop line at the break — on, swept lines terminate where they were taken. Off, they keep extending in a dimmed state.

Dim amount, colors, widths and line styles are all adjustable, including separate styling for live and swept levels.

Notes

Levels confirm after the pivot completes, which means a level appears on the chart some bars after the swing that formed it. The line is drawn back to the correct bar, but it cannot exist before the pivot is confirmed.

This is a levels tool. It does not generate entries, exits, or directional signals, and it makes no claim about what price will do when a level is reached.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rcj101208

//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//  LIQUIDITY LINES
//
//  Marks resting liquidity at confirmed swing highs and lows and extends each
//  level right until price trades through it. Once taken, the line dims and
//  stops at the bar that swept it.
//
//  Accuracy notes:
//   - Levels sit on the wick (high / low), which is where stops actually rest.
//   - Each line starts at its own pivot bar, not at the confirmation bar.
//   - Repeat touches within tolerance merge into one level and thicken it,
//     so equal highs / equal lows read as a single, heavier pool instead of a
//     stack of near-identical lines.
// ══════════════════════════════════════════════════════════════════════════════
indicator("Liquidity Lines", "LIQ", overlay = true, max_lines_count = 500)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Levels"
swingLen  = input.int(10, "Swing length", minval = 1, group = g1, tooltip = "Bars required either side of a pivot. Higher = fewer, more significant levels. Levels confirm this many bars after the pivot, but the line is drawn back to the pivot itself.")
maxPer    = input.int(25, "Max levels per side", minval = 1, maxval = 200, group = g1, tooltip = "Oldest levels are removed once this is exceeded.")
padBars   = input.int(5, "Extend past current bar", minval = 0, maxval = 100, group = g1)

g2 = "Equal levels"
mergeOn  = input.bool(true, "Merge equal highs / lows", group = g2)
mergeTol = input.float(10, "Merge tolerance (% of ATR)", minval = 0, maxval = 100, step = 5, group = g2, tooltip = "A new pivot within this distance of a live level joins it instead of drawing its own line. The line thickens with each touch.")

g3 = "Break behaviour"
breakMode   = input.string("Wick through", "Break trigger", options = ["Wick through", "Close through"], group = g3, tooltip = "Wick through = the level is taken the moment price trades past it. Close through = only a body close past it counts.")
stopAtBreak = input.bool(true, "Stop line at the break", group = g3, tooltip = "Off = swept lines keep extending, dimmed.")
sweptStyleIn = input.string("Dotted", "Swept line style", options = ["Solid", "Dashed", "Dotted"], group = g3)
dimAmt       = input.int(70, "Dim amount", minval = 0, maxval = 95, step = 5, group = g3)

g4 = "Style"
colHi     = input.color(#26a69a, "Buy-side (swing highs)", group = g4)
colLo     = input.color(#ef5350, "Sell-side (swing lows)", group = g4)
liveWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = g4)
liveStyleIn = input.string("Solid", "Live line style", options = ["Solid", "Dashed", "Dotted"], group = g4)

toStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

liveStyle  = toStyle(liveStyleIn)
sweptStyle = toStyle(sweptStyleIn)

// ── Level store ───────────────────────────────────────────────────────────────
type Lvl
    float price
    int   bx
    line  ln
    bool  swept
    int   hits

var array<Lvl> highs = array.new<Lvl>()
var array<Lvl> lows  = array.new<Lvl>()

atr = ta.atr(14)
tol = na(atr) ? 0.0 : atr * mergeTol / 100.0

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// ── New swing high ────────────────────────────────────────────────────────────
if not na(ph)
    merged = false
    if mergeOn and array.size(highs) > 0
        for i = 0 to array.size(highs) - 1
            l = array.get(highs, i)
            if not l.swept and math.abs(l.price - ph) <= tol
                l.hits += 1
                line.set_width(l.ln, math.min(liveWidth + l.hits - 1, 4))
                merged := true
                break
    if not merged
        pbar = bar_index - swingLen
        ln = line.new(pbar, ph, bar_index + padBars, ph, color = colHi, width = liveWidth, style = liveStyle)
        array.push(highs, Lvl.new(ph, pbar, ln, false, 1))
        if array.size(highs) > maxPer
            old = array.shift(highs)
            line.delete(old.ln)

// ── New swing low ─────────────────────────────────────────────────────────────
if not na(pl)
    merged = false
    if mergeOn and array.size(lows) > 0
        for i = 0 to array.size(lows) - 1
            l = array.get(lows, i)
            if not l.swept and math.abs(l.price - pl) <= tol
                l.hits += 1
                line.set_width(l.ln, math.min(liveWidth + l.hits - 1, 4))
                merged := true
                break
    if not merged
        pbar = bar_index - swingLen
        ln = line.new(pbar, pl, bar_index + padBars, pl, color = colLo, width = liveWidth, style = liveStyle)
        array.push(lows, Lvl.new(pl, pbar, ln, false, 1))
        if array.size(lows) > maxPer
            old = array.shift(lows)
            line.delete(old.ln)

// ── Extend live levels / dim swept ones ───────────────────────────────────────
if array.size(highs) > 0
    for i = 0 to array.size(highs) - 1
        l = array.get(highs, i)
        if l.swept
            if not stopAtBreak
                line.set_x2(l.ln, bar_index + padBars)
        else
            taken = bar_index > l.bx and (breakMode == "Wick through" ? high > l.price : close > l.price)
            if taken
                l.swept := true
                line.set_color(l.ln, color.new(colHi, dimAmt))
                line.set_style(l.ln, sweptStyle)
                line.set_width(l.ln, 1)
                line.set_x2(l.ln, stopAtBreak ? bar_index : bar_index + padBars)
            else
                line.set_x2(l.ln, bar_index + padBars)

if array.size(lows) > 0
    for i = 0 to array.size(lows) - 1
        l = array.get(lows, i)
        if l.swept
            if not stopAtBreak
                line.set_x2(l.ln, bar_index + padBars)
        else
            taken = bar_index > l.bx and (breakMode == "Wick through" ? low < l.price : close < l.price)
            if taken
                l.swept := true
                line.set_color(l.ln, color.new(colLo, dimAmt))
                line.set_style(l.ln, sweptStyle)
                line.set_width(l.ln, 1)
                line.set_x2(l.ln, stopAtBreak ? bar_index : bar_index + padBars)
            else
                line.set_x2(l.ln, bar_index + padBars)
````

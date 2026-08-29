<!-- tradingview-pine-id: PUB;098028efc5f24799a759ffbb2caff292 -->
<!-- tradingviewscripts-format: 1 -->
# Smart-FVG

Source: https://www.tradingview.com/script/oPWUDp0M-Smart-FVG/

## Description

Smart-FVG — Fair Value Gaps with Wick-Touch Tracking & Inverse FVG

Smart-FVG detects three-candle Fair Value Gaps and then tracks what price *does* with them. Instead of just drawing boxes, it distinguishes between untouched gaps, gaps that have been wick-tested, and gaps that have been fully mitigated — and it highlights the single most recently mitigated gap as a potential Inverse FVG (a gap that may now act as the opposite side's support/resistance).

How it works

Detection. A bullish FVG forms when the current candle's low gaps above the high from two candles back; a bearish FVG forms when the current candle's high gaps below the low from two candles back. Two quality filters keep the chart clean:

[*]Min FVG Gap — the gap must be at least this size to be drawn.
[*]Min Middle-Candle Body — the displacement candle in the middle of the pattern must have a real body of at least this size, filtering out weak, low-conviction gaps.

Both sizes can be entered in ticks (automatically scaled to the symbol's tick size — 0.25 on NQ/ES, 0.10 on GC, etc.) or in raw price points.

Wick-touch tracking. If a wick pierces into the gap but the candle closes back outside it, the FVG is recolored (gray by default). The level was tested and respected — often a sign of a partially filled gap that may still hold, but with less "fresh" liquidity than an untouched one.

Mitigation. When a candle *closes* through the far side of the gap, the FVG is considered fully mitigated and is removed from the chart. Wicks alone never mitigate — only closes.

Inverse FVG. The most recently mitigated gap is redrawn in a distinct color (purple by default) from its original starting point. A bullish FVG that price closed through often flips into resistance, and vice versa — this is the inversion (iFVG) concept. Only the single latest mitigation is shown to avoid clutter, and the highlight extends for a configurable number of bars after mitigation before freezing in place. Each new mitigation replaces the previous inverse.

Every gap also displays a dashed equilibrium line at its 50% level — a common target for partial fills and a refined entry point inside the gap.

Settings

[*]Size Inputs In Ticks — toggle between tick-based and point-based gap/body sizing
[*]Min FVG Gap / Min Middle-Candle Body — quality filters described above
[*]Max Active FVGs Per Side — caps how many bullish and bearish gaps are kept on the chart (oldest are dropped first)
[*]Colors & Line Width — bullish, bearish, wick-touched, and inverse colors are all configurable
[*]Show Inverse FVG / Inverse Display Bars — toggle the iFVG highlight and control how long it extends after mitigation

Notes

[*]Boxes are drawn as outlines with a dashed midline, keeping candles fully visible.
[*]Works on any symbol and time frame; tick-based sizing makes settings portable across futures contracts.
[*]The gap-completion candle itself can mitigate or wick-test the gap it just created, keeping behavior consistent with strict close-based rules.

This indicator is a charting tool, not a trading system. FVGs and inversions describe how price has interacted with prior inefficiencies — always combine with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("Smart-FVG", "Smart-FVG", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ─── Inputs ───────────────────────────────────────────────
useTicks    = input.bool(true, "Size Inputs In Ticks", tooltip = "ON: gap/body sizes below are in ticks (uses the symbol's tick size automatically). OFF: raw price points")
fvgGapIn    = input.float(1.0, "Min FVG Gap", minval = 0, step = 0.25)
minBodyIn   = input.float(0.0, "Min Middle-Candle Body", minval = 0, step = 0.25)
maxPerSide  = input.int(50, "Max Active FVGs Per Side", minval = 1, maxval = 200)

bullColor   = input.color(#00ff00, "Bullish Border")
bearColor   = input.color(#ff0000, "Bearish Border")
wickColor   = input.color(#808080, "Wick-Touch Border")
lw          = input.int(1, "Line Width", minval = 1, maxval = 5)

showInverse = input.bool(true, "Show Inverse FVG", tooltip = "Highlights only the most recently mitigated FVG")
invColor    = input.color(#9013FE, "Inverse Color")
invBars     = input.int(100, "Inverse Display Bars (after mitigation)", minval = 1, maxval = 2000)

gapMin  = useTicks ? fvgGapIn  * syminfo.mintick : fvgGapIn
bodyMin = useTicks ? minBodyIn * syminfo.mintick : minBodyIn

// ─── FVG object ───────────────────────────────────────────
type FVG
    box   bx
    line  eq
    float top
    float bottom
    int   startBar
    int   startTime
    bool  wick = false

var FVG[] bulls        = array.new<FVG>()
var FVG[] bears        = array.new<FVG>()
var FVG[] mitigatedNow = array.new<FVG>()

// Inverse state (only the most recently mitigated FVG is shown)
var box  invBox     = na
var line invEq      = na
var int  invStopBar = na

// ─── Helpers ──────────────────────────────────────────────
newFVG(float topP, float botP, color col) =>
    midP = (topP + botP) / 2
    bx = box.new(bar_index - 1, topP, bar_index, botP, border_color = col, border_width = lw, bgcolor = na)
    eq = line.new(bar_index - 1, midP, bar_index, midP, color = col, style = line.style_dashed, width = 1)
    FVG.new(bx, eq, topP, botP, bar_index - 1, time[1])

capSide(FVG[] arr) =>
    while array.size(arr) > maxPerSide
        FVG old = array.shift(arr)   // drop the oldest first
        box.delete(old.bx)
        line.delete(old.eq)

manageSide(FVG[] arr, bool isBull) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            f = array.get(arr, i)
            // Fully mitigated: bull = close through the bottom, bear = close through the top
            mitigated = isBull ? close <= f.bottom : close >= f.top
            if mitigated
                array.push(mitigatedNow, f)
                array.remove(arr, i)
                box.delete(f.bx)
                line.delete(f.eq)
            else
                // Wick touch: wick pierces the near edge but the close holds outside the gap
                if not f.wick
                    touched = isBull ? (low < f.top and close >= f.top) : (high > f.bottom and close <= f.bottom)
                    if touched
                        f.wick := true
                        box.set_border_color(f.bx, wickColor)
                        line.set_color(f.eq, wickColor)
                box.set_right(f.bx, bar_index)
                line.set_x2(f.eq, bar_index)

// ─── Detection (current bar completes the 3-bar pattern) ──
// prev = bar[2], middle = bar[1], next = current bar
midBody = math.abs(close[1] - open[1])
if bar_index >= 2 and midBody >= bodyMin
    // Bullish FVG: gap between prev high and current low
    if low - high[2] >= gapMin
        array.push(bulls, newFVG(low, high[2], bullColor))
        capSide(bulls)
    // Bearish FVG: gap between prev low and current high
    if low[2] - high >= gapMin
        array.push(bears, newFVG(low[2], high, bearColor))
        capSide(bears)

// ─── Mitigation / wick-touch management ───────────────────
array.clear(mitigatedNow)
manageSide(bulls, true)
manageSide(bears, false)

// ─── Inverse: most recently mitigated FVG only ────────────
if showInverse and array.size(mitigatedNow) > 0
    // Tie-break: when several mitigate on the same bar, the newest FVG wins
    FVG best = array.get(mitigatedNow, 0)
    if array.size(mitigatedNow) > 1
        for i = 1 to array.size(mitigatedNow) - 1
            f = array.get(mitigatedNow, i)
            if f.startBar > best.startBar
                best := f
    box.delete(invBox)
    line.delete(invEq)
    midP = (best.top + best.bottom) / 2
    invBox := box.new(best.startTime, best.top, time, best.bottom, xloc = xloc.bar_time, border_color = invColor, border_width = lw, bgcolor = na)
    invEq  := line.new(best.startTime, midP, time, midP, xloc = xloc.bar_time, color = invColor, style = line.style_dashed, width = 1)
    invStopBar := bar_index + invBars

// Extend the inverse box, but freeze it invBars after mitigation
if not na(invBox) and bar_index <= invStopBar
    box.set_right(invBox, time)
    line.set_x2(invEq, time)
````

<!-- tradingview-pine-id: PUB;11e65b440b5a4018a1cd011913dfab34 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweeps [ITA]

Source: https://www.tradingview.com/script/d8m6c6rU-Liquidity-Sweeps-ITA/

## Description

Spot liquidity grabs the way smart-money traders do. This indicator tracks swing highs and lows as liquidity levels, then marks the exact moment price sweeps them - wicking beyond the level and closing back inside.

Features:
- Auto-detects swing-based liquidity levels
- Marks bullish and bearish sweeps in real time
- Pending levels shown as dotted lines, swept levels turn solid
- Configurable swing sensitivity and max active levels
- Built-in alerts for both sweep directions

Feedback and suggestions welcome.

---

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
indicator("Liquidity Sweeps [ITA]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
pivotLen    = input.int(10, "Swing Lookback", minval=3, maxval=50, group="Detection")
showSwing   = input.bool(true, "Show Swing Points", group="Detection")
maxLevels   = input.int(8, "Max Active Levels", minval=1, maxval=30, group="Detection")

bullColor   = input.color(color.new(#089981, 0), "Bullish Sweep", group="Style")
bearColor   = input.color(color.new(#f23645, 0), "Bearish Sweep", group="Style")
lineColor   = input.color(color.new(color.gray, 40), "Pending Level", group="Style")
showLabels  = input.bool(true, "Show Sweep Labels", group="Style")

alertOn     = input.bool(true, "Enable Alerts", group="Alerts")

// ─── SWING DETECTION ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

// store unswept liquidity levels
var array<float> highLevels  = array.new<float>()
var array<int>   highBars     = array.new<int>()
var array<line>  highLines    = array.new<line>()
var array<float> lowLevels   = array.new<float>()
var array<int>   lowBars      = array.new<int>()
var array<line>  lowLines     = array.new<line>()

// register new swing high
if not na(ph)
    lvl  = ph
    bidx = bar_index - pivotLen
    ln = line.new(bidx, lvl, bar_index, lvl, color=lineColor, style=line.style_dotted, width=1)
    array.push(highLevels, lvl)
    array.push(highBars, bidx)
    array.push(highLines, ln)
    if array.size(highLevels) > maxLevels
        array.shift(highLevels)
        array.shift(highBars)
        line.delete(array.shift(highLines))
    if showSwing
        label.new(bidx, lvl, "", style=label.style_circle, color=color.new(bearColor, 40), size=size.tiny, yloc=yloc.abovebar)

// register new swing low
if not na(pl)
    lvl  = pl
    bidx = bar_index - pivotLen
    ln = line.new(bidx, lvl, bar_index, lvl, color=lineColor, style=line.style_dotted, width=1)
    array.push(lowLevels, lvl)
    array.push(lowBars, bidx)
    array.push(lowLines, ln)
    if array.size(lowLevels) > maxLevels
        array.shift(lowLevels)
        array.shift(lowBars)
        line.delete(array.shift(lowLines))
    if showSwing
        label.new(bidx, lvl, "", style=label.style_circle, color=color.new(bullColor, 40), size=size.tiny, yloc=yloc.belowbar)

// ─── SWEEP DETECTION ─────────────────────────────────────────────────────────
// bearish sweep: price wicks above a swing high then closes back below (liquidity grab)
bearSweep = false
if array.size(highLevels) > 0
    for i = array.size(highLevels) - 1 to 0
        lvl = array.get(highLevels, i)
        if high > lvl and close < lvl
            ln = array.get(highLines, i)
            line.set_x2(ln, bar_index)
            line.set_color(ln, bearColor)
            line.set_style(ln, line.style_solid)
            if showLabels
                label.new(bar_index, high, "Sweep", style=label.style_label_down, color=color.new(bearColor, 20), textcolor=color.white, size=size.small)
            array.remove(highLevels, i)
            array.remove(highBars, i)
            array.remove(highLines, i)
            bearSweep := true

// bullish sweep: price wicks below a swing low then closes back above
bullSweep = false
if array.size(lowLevels) > 0
    for i = array.size(lowLevels) - 1 to 0
        lvl = array.get(lowLevels, i)
        if low < lvl and close > lvl
            ln = array.get(lowLines, i)
            line.set_x2(ln, bar_index)
            line.set_color(ln, bullColor)
            line.set_style(ln, line.style_solid)
            if showLabels
                label.new(bar_index, low, "Sweep", style=label.style_label_up, color=color.new(bullColor, 20), textcolor=color.white, size=size.small)
            array.remove(lowLevels, i)
            array.remove(lowBars, i)
            array.remove(lowLines, i)
            bullSweep := true

// extend pending levels to current bar
if array.size(highLines) > 0
    for i = 0 to array.size(highLines) - 1
        line.set_x2(array.get(highLines, i), bar_index)
if array.size(lowLines) > 0
    for i = 0 to array.size(lowLines) - 1
        line.set_x2(array.get(lowLines, i), bar_index)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(bearSweep, "Bearish Liquidity Sweep", "Bearish sweep - liquidity grabbed above swing high")
alertcondition(bullSweep, "Bullish Liquidity Sweep", "Bullish sweep - liquidity grabbed below swing low")
````

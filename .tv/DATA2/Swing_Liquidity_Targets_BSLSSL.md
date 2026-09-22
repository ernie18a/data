<!-- tradingview-pine-id: PUB;cc7b209ec1b84be09cf91b997deff2d5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Swing Liquidity Targets (BSL/SSL)

Source: https://www.tradingview.com/script/Qiw5fhx7-Swing-Liquidity-Targets-BSL-SSL/

## Description

Swing Liquidity Targets (BSL/SSL) marks confirmed swing highs as buy-side liquidity (BSL) and swing lows as sell-side liquidity (SSL), each as a line extending forward from the swing.

HOW IT WORKS:

A target is marked swept the moment price wicks through it. The line freezes there and turns gray. Rather than leaving every old swing on the chart forever, unswept targets expire after a set number of calendar days, so the same setting behaves the same whether you're on a 5 minute chart or a daily one, and when two same-side targets land close together, only the one nearer to price is kept instead of stacking duplicate lines on top of each other.

NON-REPAINTING: 

pivots confirm after the bars set in Right Bars, and lines don't move once drawn.

USAGE: 

treat the lines as context for where price may be drawn to next, not as a standalone entry signal. Combine with your own structure and confirmation.

LIMITATIONS: 

like any pivot-based tool, the most recent swing won't show a target until Right Bars bars have closed after it, so very recent price action may look "missing" for a short while. That's what keeps it non-repainting rather than a bug.

WHAT YOU CAN CHANGE:

-> Left/Right Bars, pivot sensitivity for swing detection
-> Max Target Length (days), how long an unswept target stays active before it stops extending
-> Cluster Tolerance (x ATR), how close two same-side targets need to be before the weaker one is dropped
-> Show BSL / Show SSL, turn either side off completely
-> Line Style, dotted, dashed, or solid
-> Line Width
-> BSL / SSL / Swept colors
-> Show BSL/SSL Labels toggle

I hope this is of use to you! Let me know if you like it.

---

## Source Code

````pine
//@version=6
indicator("Swing Liquidity Targets (BSL/SSL)", overlay = true, max_lines_count = 480, max_labels_count = 480)

// ---------------------------------------------------------------------------
// WHAT THIS DOES
// ---------------------------------------------------------------------------
// Every confirmed swing high becomes a buy-side liquidity target (BSL) - a
// dotted line at that price, since resting buy-stops are assumed to sit just
// above old highs. Every swing low becomes sell-side liquidity (SSL) the
// same way, below. Unlike the equal-highs script, there's no second-touch
// requirement here - a swing only needs to happen once to become a target.
// The line keeps extending right, bar by bar, until price actually trades
// through it (a wick beyond the level, not a close - that's when resting
// orders there would really get filled). The moment that happens the line
// freezes exactly where it got swept and turns gray, so you can still see
// it was there without it competing visually with the live targets.
//
// When two still-live targets of the same kind end up close together, only
// one survives - the more conservative one, closer to where price actually
// is: the lower of two nearby BSLs, the higher of two nearby SSLs. The
// other gets deleted outright rather than left cluttering the chart.
// ---------------------------------------------------------------------------

grpPivot = "Pivot Detection"
leftBars  = input.int(5, "Left Bars",  minval = 1, group = grpPivot)
rightBars = input.int(5, "Right Bars", minval = 1, group = grpPivot)

grpStyle = "Style"
colorHigh   = input.color(color.new(color.red, 0),   "BSL (Buy-Side Liquidity) Color", group = grpStyle)
colorLow    = input.color(color.new(color.teal, 0),  "SSL (Sell-Side Liquidity) Color", group = grpStyle)
sweptColor  = input.color(color.new(color.gray, 40), "Swept Line Color", group = grpStyle)
lineStyleIn = input.string("Dotted", "Line Style", options = ["Dotted", "Dashed", "Solid"], group = grpStyle)
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 4, group = grpStyle)
showLabels  = input.bool(true, "Show BSL / SSL Labels", group = grpStyle)
showBSL     = input.bool(true, "Show BSL (Buy-Side Liquidity)", group = grpStyle)
showSSL     = input.bool(true, "Show SSL (Sell-Side Liquidity)", group = grpStyle)

lineStyle = lineStyleIn == "Solid" ? line.style_solid : lineStyleIn == "Dashed" ? line.style_dashed : line.style_dotted
// A target that never gets swept would otherwise keep extending forever -
// on a chart with a few years of history that's a line stretching across
// the whole thing. Once a target reaches this age it just stops growing
// and is left wherever it got to - not recolored, since it wasn't actually
// swept, it simply ran out of runway.
//
// This is measured in calendar days, not bars, on purpose. A bar count
// means something completely different depending on the timeframe - 500
// bars is under two days on a 5 minute chart but about eight months on a
// 12h chart, so a single default either does nothing or is absurdly long
// depending what you're looking at. Days behave the same everywhere.
maxTargetDays = input.int(14, "Max Target Length (days)", minval = 1, group = grpStyle)
maxAgeMs = maxTargetDays * 86400000
// How close two still-live targets need to be, in ATR, before the weaker
// one gets dropped. ATR-based rather than a fixed percentage for the same
// reason the equal-highs script uses it - it self-adjusts to both the
// instrument's price level and how choppy the current timeframe is.
clusterATRMult = input.float(0.5, "Cluster Tolerance (x ATR)", minval = 0.001, step = 0.05, group = grpStyle)

// Fixed, not exposed as inputs. atrLen is the standard ATR lookback.
// maxKeptPerSide just caps how many target lines (per side) stay on the
// chart before the oldest ones get quietly deleted to make room - a safety
// valve against the drawing-object limit on a chart with a lot of history,
// not a setting that changes what you see day to day.
atrLen         = 14
maxKeptPerSide = 150

atrVal     = ta.atr(atrLen)
clusterTol = atrVal * clusterATRMult

// ---------------------------------------------------------------------------
// STATE - one set of parallel arrays per side. Every target, swept or not,
// stays in here (up to maxKeptPerSide) so a swept line can still be trimmed
// away once it's old enough. A target removed by clustering (superseded by
// a better nearby one) is deleted outright instead, line, label and all.
// ---------------------------------------------------------------------------
var array<float> highPrices     = array.new_float(0)
var array<int>   highStartBars  = array.new_int(0)
var array<int>   highStartTimes = array.new_int(0)
var array<line>  highLines      = array.new_line(0)
var array<label> highLabels     = array.new_label(0)
var array<bool>  highSwept      = array.new_bool(0)
var array<bool>  highCapped     = array.new_bool(0)

var array<float> lowPrices     = array.new_float(0)
var array<int>   lowStartBars  = array.new_int(0)
var array<int>   lowStartTimes = array.new_int(0)
var array<line>  lowLines      = array.new_line(0)
var array<label> lowLabels     = array.new_label(0)
var array<bool>  lowSwept      = array.new_bool(0)
var array<bool>  lowCapped     = array.new_bool(0)

// ---------------------------------------------------------------------------
// "a is the more conservative / inner level" - the lower of two BSLs
// (highs), or the higher of two SSLs (lows). That's the one that survives
// when two targets turn out to be the same zone.
// ---------------------------------------------------------------------------
isInner(float a, float b, bool isHigh) =>
    isHigh ? a < b : a > b

// ---------------------------------------------------------------------------
// Add a freshly confirmed swing as a new liquidity target - unless a
// still-live target of the same kind already covers this zone, in which
// case this one is redundant and gets skipped; and any still-live target
// this one outclasses gets deleted rather than left behind.
// ---------------------------------------------------------------------------
addTarget(array<float> prices, array<int> startBars, array<int> startTimes, array<line> lines, array<label> labels,
     array<bool> swept, array<bool> capped, float price, int startBar, int startTime, color col, string kind) =>
    isHigh = kind == "BSL"

    dominated = false
    if array.size(prices) > 0
        for i = array.size(prices) - 1 to 0
            if not array.get(swept, i) and not array.get(capped, i)
                p = array.get(prices, i)
                if math.abs(price - p) <= clusterTol and isInner(p, price, isHigh)
                    dominated := true

    if not dominated
        if array.size(prices) > 0
            for i = array.size(prices) - 1 to 0
                if not array.get(swept, i) and not array.get(capped, i)
                    p = array.get(prices, i)
                    if math.abs(price - p) <= clusterTol and isInner(price, p, isHigh)
                        line.delete(array.get(lines, i))
                        oldLbl = array.get(labels, i)
                        if not na(oldLbl)
                            label.delete(oldLbl)
                        array.remove(prices, i)
                        array.remove(startBars, i)
                        array.remove(startTimes, i)
                        array.remove(lines, i)
                        array.remove(labels, i)
                        array.remove(swept, i)
                        array.remove(capped, i)

        ln = line.new(x1 = startBar, y1 = price, x2 = bar_index, y2 = price,
             xloc = xloc.bar_index, color = col, style = lineStyle, width = lineWidth)
        label lb = na
        if showLabels
            lb := label.new(x = startBar, y = price,
                 text = kind,
                 xloc = xloc.bar_index, yloc = isHigh ? yloc.abovebar : yloc.belowbar,
                 style = isHigh ? label.style_label_down : label.style_label_up,
                 color = color.new(col, 85), textcolor = col, size = size.tiny)

        array.push(prices, price)
        array.push(startBars, startBar)
        array.push(startTimes, startTime)
        array.push(lines, ln)
        array.push(labels, lb)
        array.push(swept, false)
        array.push(capped, false)
        if array.size(prices) > maxKeptPerSide
            line.delete(array.get(lines, 0))
            oldLbl2 = array.get(labels, 0)
            if not na(oldLbl2)
                label.delete(oldLbl2)
            array.shift(prices)
            array.shift(startBars)
            array.shift(startTimes)
            array.shift(lines)
            array.shift(labels)
            array.shift(swept)
            array.shift(capped)

// ---------------------------------------------------------------------------
// Extend every still-active target to the current bar, and freeze + fade
// any that just got swept (price wicked through the level this bar), or
// just stop (no recolor) any that aged past the max target length.
// ---------------------------------------------------------------------------
updateTargets(array<float> prices, array<int> startTimes, array<line> lines, array<bool> swept, array<bool> capped, bool isHigh) =>
    // Pine's "for i = 0 to N-1" doesn't skip when N is 0 - it still runs
    // once, counting downward from 0 to -1, which is exactly what threw
    // the out-of-bounds error on bar 0 before any target existed yet. Has
    // to be guarded explicitly rather than trusted to a false range.
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            if not array.get(swept, i) and not array.get(capped, i)
                lvl = array.get(prices, i)
                ln  = array.get(lines, i)
                ageMs = time - array.get(startTimes, i)
                if ageMs >= maxAgeMs
                    array.set(capped, i, true)
                else
                    line.set_x2(ln, bar_index)
                    sweptNow = isHigh ? high >= lvl : low <= lvl
                    if sweptNow
                        line.set_color(ln, sweptColor)
                        array.set(swept, i, true)

// ---------------------------------------------------------------------------
// PIVOT DETECTION AND DISPATCH
// ---------------------------------------------------------------------------
ph = ta.pivothigh(leftBars, rightBars)
pl = ta.pivotlow(leftBars, rightBars)
pivotBarIndex = bar_index - rightBars
pivotBarTime  = time[rightBars]

if not na(ph) and showBSL
    addTarget(highPrices, highStartBars, highStartTimes, highLines, highLabels, highSwept, highCapped, ph, pivotBarIndex, pivotBarTime, colorHigh, "BSL")

if not na(pl) and showSSL
    addTarget(lowPrices, lowStartBars, lowStartTimes, lowLines, lowLabels, lowSwept, lowCapped, pl, pivotBarIndex, pivotBarTime, colorLow, "SSL")

updateTargets(highPrices, highStartTimes, highLines, highSwept, highCapped, true)
updateTargets(lowPrices, lowStartTimes, lowLines, lowSwept, lowCapped, false)
````

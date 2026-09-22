<!-- tradingview-pine-id: PUB;84a8a6b27f854a5c995ba136a9fc2e1c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Equal Highs & Lows [ITA]

Source: https://www.tradingview.com/script/OBTZlQ8I-Equal-Highs-Lows-ITA/

## Description

🟠 OVERVIEW

Equal Highs & Lows marks the places where liquidity pools build, and then
tracks what happens to them.

When two swing highs form at almost the same price, the stops of everyone who
sold that level sit just above it. The same is true in reverse below two equal
lows. Those clusters are what price often reaches for before it turns, and they
are visible on the chart long before anything happens to them.

Most tools that find these draw the two swings and stop there. This one keeps
the level alive until price actually takes it, then marks it as swept rather
than deleting it, so you can look back and see whether a symbol respects its
pools at all before you trade one.

🟠 CONCEPTS

* Equal Highs (EQH) - Two swing highs within a set tolerance of each other.
Stop orders rest above them.
* Equal Lows (EQL) - Two swing lows within tolerance. Stops rest below.
* Liquidity Pool - The cluster of resting orders those stops form. It is a
reason for price to travel somewhere, not a reason for it to reverse there.
* Sweep - Price trading through the level and taking the orders. What happens
immediately after the sweep is the part that matters.

🟠 FEATURES

🔹 Equality tolerance is set as a percentage of price rather than in points, so
the same setting behaves consistently on a five dollar stock and a seven hundred
dollar index

🔹 The level is drawn at the higher of the two equal highs, and the lower of the
two equal lows, because that is where the stops actually sit. Averaging the two
puts the line underneath the liquidity it is meant to mark

🔹 Levels extend forward on every bar until they are taken, so an untouched pool
stays visible for as long as it survives

🔹 Swept pools are greyed out and labelled instead of being removed, which
leaves a record of how the symbol has treated its pools historically

🔹 A cap on active pools, so old levels retire instead of filling the chart

🔹 Separate alerts for equal highs taken and equal lows taken

🟠 HOW TO USE

Start with the tolerance. It is the setting that decides everything else. On a
daily chart 0.1 to 0.3 percent is usually right. Intraday, drop it to 0.05 to
0.15. If you are seeing almost no pools, raise it. If everything is a pool,
lower it.

Read an unswept level as a destination, not a wall. Liquidity sitting above the
current price is a reason to expect price to reach up there at some point. It is
not a reason to short it.

The information is in what follows the sweep. Price taking equal highs and then
continuing up means the pool was simply passed through. Price taking them and
immediately failing back below is the sequence that traders are usually looking
for, and the sweep alert is there so you do not have to watch for it.

Swing Lookback controls how significant a swing has to be before it counts.
Raise it for fewer and more meaningful pools.

🟠 CONCLUSION

Equal highs and lows are easy to see once someone points at them and easy to
miss while a chart is moving. This marks them as they form, keeps them until
they are taken, and leaves the record behind.

---

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
indicator("Equal Highs & Lows [ITA]", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
pivotLen   = input.int(8, "Swing Lookback", minval=3, maxval=30, group="Detection")
tolPct     = input.float(0.25, "Equality Tolerance (%)", minval=0.01, maxval=3.0, step=0.05, group="Detection", tooltip="How close two swings must be (as % of price) to count as equal. Lower = stricter. Try 0.1-0.3 for daily charts, 0.05-0.15 for intraday.")
maxPools   = input.int(6, "Max Active Pools", minval=1, maxval=20, group="Detection")
removeSwept= input.bool(true, "Mark Swept Pools", group="Detection")

eqhColor   = input.color(color.new(#f23645, 0), "Equal Highs (EQH)", group="Style")
eqlColor   = input.color(color.new(#089981, 0), "Equal Lows (EQL)", group="Style")
sweptColor = input.color(color.new(color.gray, 60), "Swept Pool", group="Style")
showLabels = input.bool(true, "Show EQH/EQL Labels", group="Style")
lblSizeStr = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large"], group="Style")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=4, group="Style")

lblSize = lblSizeStr == "Tiny" ? size.tiny : lblSizeStr == "Small" ? size.small : lblSizeStr == "Large" ? size.large : size.normal

// ─── SWING DETECTION ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float lastPH    = na
var int   lastPHbar = na
var float lastPL    = na
var int   lastPLbar = na

// pools: price level + line + swept flag
var array<float> eqhLevels = array.new<float>()
var array<line>  eqhLines  = array.new<line>()
var array<float> eqlLevels = array.new<float>()
var array<line>  eqlLines  = array.new<line>()

tol = close * tolPct / 100

// detect equal highs: new pivot high within tolerance of the previous one
if not na(ph)
    if not na(lastPH) and math.abs(ph - lastPH) <= tol
        lvl = math.max(ph, lastPH) // liquidity rests above the higher of the two
        ln = line.new(lastPHbar, lvl, bar_index - pivotLen, lvl, color=eqhColor, style=line.style_dashed, width=lineWidth)
        array.push(eqhLevels, lvl)
        array.push(eqhLines, ln)
        if showLabels
            label.new(bar_index - pivotLen, lvl, "EQH", style=label.style_label_down, color=color.new(eqhColor, 10), textcolor=color.white, size=lblSize)
        if array.size(eqhLevels) > maxPools
            array.shift(eqhLevels)
            line.delete(array.shift(eqhLines))
    lastPH := ph
    lastPHbar := bar_index - pivotLen

// detect equal lows
if not na(pl)
    if not na(lastPL) and math.abs(pl - lastPL) <= tol
        lvl = math.min(pl, lastPL) // liquidity rests below the lower of the two
        ln = line.new(lastPLbar, lvl, bar_index - pivotLen, lvl, color=eqlColor, style=line.style_dashed, width=lineWidth)
        array.push(eqlLevels, lvl)
        array.push(eqlLines, ln)
        if showLabels
            label.new(bar_index - pivotLen, lvl, "EQL", style=label.style_label_up, color=color.new(eqlColor, 10), textcolor=color.white, size=lblSize)
        if array.size(eqlLevels) > maxPools
            array.shift(eqlLevels)
            line.delete(array.shift(eqlLines))
    lastPL := pl
    lastPLbar := bar_index - pivotLen

// ─── SWEEP DETECTION ─────────────────────────────────────────────────────────
eqhSwept = false
if array.size(eqhLevels) > 0
    for i = array.size(eqhLevels) - 1 to 0
        lvl = array.get(eqhLevels, i)
        ln  = array.get(eqhLines, i)
        line.set_x2(ln, bar_index)
        if high > lvl
            eqhSwept := true
            if removeSwept
                line.set_color(ln, sweptColor)
                if showLabels
                    label.new(bar_index, lvl, "Swept", style=label.style_label_down, color=color.new(sweptColor, 20), textcolor=color.white, size=lblSize)
            array.remove(eqhLevels, i)
            array.remove(eqhLines, i)

eqlSwept = false
if array.size(eqlLevels) > 0
    for i = array.size(eqlLevels) - 1 to 0
        lvl = array.get(eqlLevels, i)
        ln  = array.get(eqlLines, i)
        line.set_x2(ln, bar_index)
        if low < lvl
            eqlSwept := true
            if removeSwept
                line.set_color(ln, sweptColor)
                if showLabels
                    label.new(bar_index, lvl, "Swept", style=label.style_label_up, color=color.new(sweptColor, 20), textcolor=color.white, size=lblSize)
            array.remove(eqlLevels, i)
            array.remove(eqlLines, i)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(eqhSwept, "Equal Highs Swept", "Liquidity above equal highs has been taken")
alertcondition(eqlSwept, "Equal Lows Swept",  "Liquidity below equal lows has been taken")
````

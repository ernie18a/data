# Apex Pivot & S/R Dynamics [Pineify]

- url: https://www.tradingview.com/script/tz0ecgkc-Apex-Pivot-S-R-Dynamics-Pineify/
- type: indicator
- pine_id: PUB;3274a3f2628a4694b313a7402676e27d
- version: 1.0

## Description

[b]Apex Pivot & S/R Dynamics[/b]

This indicator maps structural support and resistance directly from confirmed pivot highs and lows, then tracks each level in real time until price decisively closes through it. Rather than drawing static zones at fixed intervals, every line is anchored to an actual swing point and extended bar by bar — the moment a close-based breach occurs, the line is deleted and a breakout label appears. The result is a chart that reflects only the levels that are still relevant right now.

[b]Key Features[/b]

[list]
[*]Pivot-confirmed S/R lines drawn at the exact bar where a swing high or low was established

[*]Close-based breakout detection with a one-bar confirmation filter — no reaction to wicks alone

[*]Automatic line removal on breach, keeping the chart free of invalidated levels

[*]Configurable cap on active lines per side; oldest unbroken levels drop off when the limit is hit

[*]Separate color controls for resistance, support, bullish breakout labels, and bearish breakout labels
[/list]

[b]How It Works[/b]

Pine's built-in [i]ta.pivothigh()[/i] and [i]ta.pivotlow()[/i] functions require price to form a local extreme confirmed by [i]length[/i] bars on both sides. A pivot confirmed with length=15 means the indicator "sees" it 15 bars after it forms — and draws the line aligned back to that original swing bar. This lag is inherent to pivot detection and trades off responsiveness for confirmation quality.

Each confirmed pivot spawns a dashed horizontal line stored in a typed array alongside its exact price. Every subsequent bar, the loop iterates through active lines and extends them to the current bar. When a close-above-resistance or close-below-support transition occurs (previous close on the wrong side, current close on the right side), the breakout condition fires: the line is deleted from the array, an annotated label is placed, and the level is gone from the chart permanently.

[list=1]
[*]Bars accumulate until a swing extreme is confirmed on both sides

[*]A dashed line is created at the pivot price, extending right indefinitely

[*]Each bar, the loop checks whether price has closed through each level

[*]On breach: label placed, line deleted, level removed from active tracking

[*]If unbroken levels exceed the configured cap, the oldest is silently removed
[/list]

[b]How the Components Work Together[/b]

The pivot detection sets the quality bar for which prices become levels — only price extremes that the market has already tested and respected on both sides qualify. The one-bar close confirmation then filters out wicks that pierce a level intrabar but don't follow through: a single candle that closes back inside the range doesn't trigger a breakout. Together, these two filters mean the breakout label fires on the first candle that suggests actual intent to move away from the level, not just noise around it.

The array-based memory management is what separates this from simpler implementations that draw lines and forget them. Because each line object is tracked with its price level, the indicator can cleanly unwind invalidated structure rather than letting stale lines accumulate across months of history.

[b]Trading Ideas and Insights[/b]

[list]
[*]On a retest setup: watch for price to pull back to a freshly broken resistance level (now acting as support) without triggering a new bearish breakout label — that silence is the confirmation

[*]When multiple resistance lines cluster within a few ticks of each other, the zone represents confluent supply; a breakout label through that cluster carries more weight than a breach of an isolated swing

[*]Use the breakout label count per session as a rough measure of trend strength — trending days tend to fire several same-direction labels in sequence, while ranging days flip back and forth

[*]On higher timeframes (daily, weekly), the lines mark major structural zones; consider using a tighter lookback (8–10) on intraday charts where swing structure is denser
[/list]

Past behavior at these levels does not guarantee future outcomes. S/R analysis works best when combined with volume, momentum, or broader context rather than used in isolation.

[b]Unique Aspects[/b]

[list]
[*]Lines are anchored to their originating pivot bar visually — the small triangle marker shows exactly which candle created each level, so you can assess the quality of the original swing without scrolling back

[*]Close-based breakout confirmation with a prior-bar check is more conservative than most pivot S/R scripts, which often fire on any penetration regardless of close location

[*]The self-cleaning design — lines disappear when breached and oldest lines drop when the cap is hit — makes the chart readable across all timeframes without manual cleanup
[/list]

[b]How to Use[/b]

[list=1]
[*]Add to any chart; the indicator overlays directly on price with no separate pane

[*]Adjust "Pivot Lookback" to match your timeframe — higher values (20–30) on daily charts identify major structure; lower values (5–10) on intraday charts capture faster swings

[*]Red dashed lines are active resistance levels; green dashed lines are active support levels

[*]A blue "B" label above a bar signals a bullish breakout through resistance; an orange "B" below signals a bearish breakdown through support

[*]If the chart becomes crowded, lower "Max Active Lines" to keep only the most recent unbroken levels visible
[/list]

[b]Customization[/b]

[list]
[*][b]Pivot Lookback[/b] (default: 15) — Controls how many bars on each side must be lower/higher to confirm a pivot. Increasing this confirms stronger, less frequent levels; decreasing it produces more levels with earlier detection but more sensitivity to minor swings.

[*][b]Highlight Breakouts[/b] (default: on) — Toggles the breakout labels. Turn off if you only want the S/R lines without annotation.

[*][b]Max Active Lines[/b] (default: 15) — Caps the number of lines per side. On instruments with very dense swing structure or long histories, reducing this to 8–10 keeps the chart uncluttered.

[*][b]Line and Label Colors[/b] — Four separate color inputs for resistance lines, support lines, bullish breakout labels, and bearish breakout labels. Adjust to match your chart theme.
[/list]

[b]Conclusion[/b]

Apex Pivot & S/R Dynamics automates the manual process of marking swing highs and lows, extending them forward, and cleaning them up when they are no longer valid. The close-based breakout filter and automatic array management mean the chart reflects current market structure rather than accumulated history. Traders focused on price action and structural levels — particularly those who trade retests and breakout continuations — will find this a practical alternative to manually drawn S/R zones.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//
// Apex Pivot & S/R Dynamics
// --------------------------
// Identifies pivot highs and lows using a configurable lookback window,
// then projects those price levels forward as dynamic support/resistance lines.
// When price closes decisively through a level, the line is removed and a
// breakout label is placed — keeping the chart clean as levels are invalidated.
//
// Three operating states:
//   1. Formation  — a new pivot is confirmed and a S/R line is drawn at that price
//   2. Hold       — price respects the level; the line extends bar by bar
//   3. Break      — price closes through the level; line is deleted, label fired
//

//@version=6
indicator("Apex Pivot & S/R Dynamics", overlay=true, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grp_pivot  = "Pivot Settings"
grp_visual = "Aesthetics & Colors"

length     = input.int(15,   "Pivot Lookback",        minval=2, maxval=100, group=grp_pivot,  tooltip="Number of bars to look left and right when confirming a pivot. Higher values confirm stronger structural levels but introduce more lag.")
showBreaks = input.bool(true,"Highlight Breakouts",              group=grp_pivot,  tooltip="Place a label on the bar where price closes through a support or resistance level.")
maxLines   = input.int(15,   "Max Active Lines",       minval=5, maxval=50,  group=grp_pivot,  tooltip="Cap on how many S/R lines can be on screen at once. The oldest unbroken level is removed when this limit is exceeded.")

colRes       = input.color(#f23645, "Resistance Line",       group=grp_visual, tooltip="Color for pivot-high resistance lines.")
colSup       = input.color(#089981, "Support Line",          group=grp_visual, tooltip="Color for pivot-low support lines.")
colBreakBull = input.color(#2157f3, "Bullish Breakout Label",group=grp_visual, tooltip="Label color when price closes above a resistance level.")
colBreakBear = input.color(#ff9800, "Bearish Breakout Label",group=grp_visual, tooltip="Label color when price closes below a support level.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// Custom type to keep a line handle and its price level together.
// Storing the price separately avoids repeated line.get_price() calls.
type lineObj
    line   ln
    float  priceLevel

var lineObj[] resLines = array.new<lineObj>()
var lineObj[] supLines = array.new<lineObj>()

// ta.pivothigh/low confirm a pivot `length` bars into the past, so the returned
// value is valid on the bar that is `length` bars after the actual pivot bar.
// We draw the line starting at bar_index - length to align it with the pivot candle.
ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low,  length, length)

//---------------------------------------------------------------------------------------------------------------------}
// S/R LINE MANAGEMENT
//---------------------------------------------------------------------------------------------------------------------{

if not na(ph)
    newResLine = line.new(bar_index - length, ph, bar_index - length, ph, xloc.bar_index, extend.right, colRes, line.style_dashed, 2)
    array.push(resLines, lineObj.new(newResLine, ph))

if not na(pl)
    newSupLine = line.new(bar_index - length, pl, bar_index - length, pl, xloc.bar_index, extend.right, colSup, line.style_dashed, 2)
    array.push(supLines, lineObj.new(newSupLine, pl))

// Iterate newest-to-oldest so array.remove() doesn't shift indices mid-loop.
// A close-above-resistance breakout requires the previous close to have been at or below
// the level — this one-bar confirmation reduces noise from brief wicks through the line.
if array.size(resLines) > 0
    for i = array.size(resLines) - 1 to 0
        lineObj resObj    = array.get(resLines, i)
        line    ln        = resObj.ln
        float   priceLevel = resObj.priceLevel

        line.set_x2(ln, bar_index)
        line.set_extend(ln, extend.right)

        if close > priceLevel and close[1] <= priceLevel
            if showBreaks
                label.new(bar_index, high, "B", xloc.bar_index, yloc.abovebar, colBreakBull, label.style_label_down, color.white, size.small, text.align_center, "Bullish Breakout above " + str.tostring(priceLevel, format.mintick))
            array.remove(resLines, i)
            line.delete(ln)

if array.size(supLines) > 0
    for i = array.size(supLines) - 1 to 0
        lineObj supObj    = array.get(supLines, i)
        line    ln        = supObj.ln
        float   priceLevel = supObj.priceLevel

        line.set_x2(ln, bar_index)
        line.set_extend(ln, extend.right)

        if close < priceLevel and close[1] >= priceLevel
            if showBreaks
                label.new(bar_index, low, "B", xloc.bar_index, yloc.belowbar, colBreakBear, label.style_label_up, color.white, size.small, text.align_center, "Bearish Breakout below " + str.tostring(priceLevel, format.mintick))
            array.remove(supLines, i)
            line.delete(ln)

// Drop the oldest unbroken level when the cap is hit, preventing chart clutter
// on instruments with dense swing structure over long timeframes.
if array.size(resLines) > maxLines
    lineObj oldestRes = array.shift(resLines)
    line.delete(oldestRes.ln)

if array.size(supLines) > maxLines
    lineObj oldestSup = array.shift(supLines)
    line.delete(oldestSup.ln)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

// Small triangle markers at confirmed pivot bars give immediate visual reference
// for where each line originated, without cluttering the price action.
plotshape(ph, title="Pivot High", location=location.abovebar, style=shape.triangledown, color=colRes, size=size.tiny)
plotshape(pl, title="Pivot Low",  location=location.belowbar, style=shape.triangleup,   color=colSup, size=size.tiny)
````

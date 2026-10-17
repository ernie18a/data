# XI0033 Williams Fractal

- url: https://www.tradingview.com/script/5Jms2RoO-XI0033-Williams-Fractal/
- type: indicator
- pine_id: PUB;6fcb1b75a15a4dba81a834799f6decca
- version: 2.0

## Description

A Williams fractal confirms late by definition: the pattern is complete only after the bars to its right have closed, so the marker always appears in the past. This script keeps the classic fractal template — three- or five-bar — and adds the one thing the classic version cannot show: the bar that is about to become a fractal, before the confirmation arrives.

It draws triangles for confirmed fractal highs and lows, plus one highlighted triangle for the last potential fractal on the live edge. Nothing else: no lines, no levels, no signals.

[b]Confirmed fractals[/b]

A fractal high is a bar whose high stands above the highs of its neighbours; a fractal low mirrors that on the lows. The 3-bar mode compares one neighbour on each side, the 5-bar mode two on each side — the original Bill Williams definition. The Periods input sets how many bars back the reference bar sits. Confirmed fractals are painted as muted grey triangles above the highs and below the lows, and once the pattern that produced them is closed, they are history: they do not move and do not disappear.

[image]https://www.tradingview.com/x/rSKkUuEl/[/image]

Confirmed fractal highs and lows in the muted default colour: every triangle marks a bar whose extreme beat its neighbours on both sides, printed only after the pattern completed.

[b]The last potential fractal[/b]

This is the addition. One bar to the right of the last confirmable centre there is always a candidate: a bar already higher (or lower) than its closed neighbours, waiting only for the current bar to keep its distance. The script highlights that candidate with an orange triangle — pointing down above a potential high, pointing up below a potential low — so the developing swing is visible before it becomes official.

The highlight exists only on the live bar. It is recalculated tick by tick, disappears the moment price violates the candidate, and is deliberately dropped on the bar's final update, so it never leaves a trace in the chart history. Scroll back and you will find only confirmed fractals.

[image]https://www.tradingview.com/x/GfsghR39/[/image]

Left: the orange triangle under the newest low is the last potential fractal. Right, a few bars later: that low now carries a grey confirmed triangle — the preview left no trace — and a new potential fractal already sits above the latest high.

[b]What repaints, and what does not[/b]

The potential marker repaints by design — that is its job. It is a live preview that appears, moves and vanishes with the current bar, and it is intentionally not committed to history. Confirmed fractals in the default 3-bar mode are built from closed bars only, so once a triangle prints, it is final. In the 5-bar mode with the default period, the newest confirmation still involves the forming bar's extreme, so it can appear and be withdrawn until that bar closes; after the close it is final. And every confirmed fractal is late by definition — the triangle appears above a bar that is already in the past, because that is what confirmation means.

[b]What is reused, and what is new[/b]

The confirmed-fractal logic is the classic Bill Williams fractal template as coded by Mit Nayi, reused open-source with attribution in the source header. What this edit adds: the port to Pine Script v6, and the whole potential-fractal layer — the candidate detection one bar to the right of the confirmable centre, and the barstate mechanism that shows the preview on the live bar only and drops it on the bar's final update, so it never piles up in history.

[b]What it does not do[/b]

It gives no signals. A fractal marks a local extreme, and most local extremes get traded through; on their own they are not entries. This is a structural marker — swing logic, liquidity maps and ICT-style analysis use fractals as raw material, and the potential marker only tells you where the next one may appear. The decision stays yours.

[b]The Inputs allow you to set:[/b]


Periods: how many bars back the fractal centre sits; the triangles are drawn on that centre bar
3 or 5 Bar Fractal: one or two neighbours compared on each side
Show last potential fractal: the live-edge preview on or off
Potential down and up fractal colours


[b]About the chart[/b]

BYBIT:BTCUSDT.P, 5-minute chart. The only script on it is this one, with default settings: muted grey triangles mark confirmed fractal highs and lows across the chart, and the orange triangle at the right edge is the last potential fractal, not yet confirmed. No other indicators, no drawings.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © XI0033
// Confirmed-fractal logic reused from the open-source Williams Fractal template by Mit Nayi, under the same license.
// XI0033 additions: Pine Script v6 port and the last-potential-fractal live preview (candidate detection + commit guard).
// v2: potential-marker colours passed as series (ternary). editable=false freezes input-qualified plot colours
//     at their compile defaults; series colours bypass the Style property system and read the inputs live.
//@version=6
indicator("XI0033 Williams Fractal", shorttitle="XI0033 Williams Fractal", overlay=true)

// ---------------- Inputs ----------------
n             = input.int(2, title="Periods", minval=2)
fractalBars   = input.string("3", title="3 or 5 Bar Fractal", options=["3", "5"])

showPotential = input.bool(true, title="Show last potential fractal")
potDnColor    = input.color(color.new(color.orange, 15), title="Potential down fractal color")
potUpColor    = input.color(color.new(#2962ff, 15),      title="Potential up fractal color")

is5 = fractalBars == "5"

// ---------------- Confirmed fractals (original logic) ----------------
dnFractal = is5 ? ((high[n-2] < high[n]) and (high[n-1] < high[n]) and (high[n+1] < high[n]) and (high[n+2] < high[n])) : ((high[n-1] < high[n]) and (high[n+1] < high[n]))
upFractal = is5 ? ((low[n-2]  > low[n])  and (low[n-1]  > low[n])  and (low[n+1]  > low[n])  and (low[n+2]  > low[n]))  : ((low[n-1]  > low[n])  and (low[n+1]  > low[n]))

// ---------------- Potential (not-yet-confirmed) fractal ----------------
// Candidate sits one bar to the right of a confirmed centre (high[n-1] / low[n-1]).
dnPotential = is5 ? ((high[n] < high[n-1]) and (high[n+1] < high[n-1]) and (high[n-2] < high[n-1])) : ((high[n] < high[n-1]) and (high[n-2] < high[n-1]))
upPotential = is5 ? ((low[n]  > low[n-1])  and (low[n+1]  > low[n-1])  and (low[n-2]  > low[n-1]))  : ((low[n]  > low[n-1])  and (low[n-2]  > low[n-1]))

// Show potential only on the live bar and drop it the instant the bar closes,
// so nothing piles up in history. (isrealtime & isconfirmed = the commit tick.)
potShow = barstate.islast and not (barstate.isrealtime and barstate.isconfirmed)

// ---------------- Plots ----------------
// Potential first, confirmed after -> confirmed is drawn ON TOP of potential.
// Potential shapes are editable=false: their colours live in Inputs, next to the toggle.
// Colours are series-wrapped so the Inputs pickers actually drive them (see v2 note).
plotshape(showPotential and potShow and dnPotential, title="Potential fractal high", style=shape.triangledown, location=location.abovebar, offset=-(n - 1), color=dnPotential ? potDnColor : na, editable=false)
plotshape(showPotential and potShow and upPotential, title="Potential fractal low",  style=shape.triangleup,   location=location.belowbar, offset=-(n - 1), color=upPotential ? potUpColor : na, editable=false)

// Confirmed (white), drawn on the fractal's centre bar for any Periods
plotshape(dnFractal, title="Fractal high", style=shape.triangledown, location=location.abovebar, offset=-n, color=color.new(color.white, 50))
plotshape(upFractal, title="Fractal low",  style=shape.triangleup,   location=location.belowbar, offset=-n, color=color.new(color.white, 50))
````

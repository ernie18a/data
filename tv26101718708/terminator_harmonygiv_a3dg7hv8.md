# Terminator HarmonyGiv

- url: https://www.tradingview.com/script/A3dG7Hv8-Terminator-HarmonyGiv/
- type: indicator
- pine_id: PUB;b747a88686cd4563ad320fb59904e9b7
- version: 4.0

## Description

Terminator Harmony

A time-projection tool that predicts when the day's next moves are likely to happen — a Fibonacci Time Zone engine anchored to the session open and the day's first expansion swing.

Most indicators tell you where price might go. Terminator Harmony tells you when. It measures the time it took the market to travel from the day's open to the first swing that launched a real expansion, then projects that rhythm forward across the rest of the session.

How it works

It's built on two anchors:

- Anchor 0 — the day open. Auto-placed at either midnight ET (true day open) or the Globex 18:00 ET futures open, your choice. In Globex mode it correctly grabs the most recent 18:00 at or before your swing (the prior evening if your swing is in the morning).
- Anchor 1 — the expansion swing. The first structural swing high/low that caused a relatively big leg of expansion. This is a discretionary read, so you place it with one click and it becomes a draggable dot — move it and the whole projection re-casts live.

The distance between them (base = Anchor1 − Anchor0) becomes the market's time "unit" for the day. The indicator then casts vertical zone lines forward at multiples of that base — the times where turns, exhaustions, and new legs tend to cluster.

Projection modes

- Equal steps (default) — evenly spaced zones (1×, 2×, 3×… the base).
- Fibonacci sequence — zones at 1, 2, 3, 5, 8, 13, 21… (classic Fib Time Zone spacing).
- Fib ratios — a fib-retracement ladder on the time axis: the two anchors (0 and 1.0, in orange) plus standard extensions past the swing — 1.272, 1.618, 2.0, 2.618, 3.618, 4.236, then the golden powers 6.854 (φ⁴) and 11.09 (φ⁵) so it spans the full day.
- Custom — type your own multiples (comma-separated).

Usage

Each day, drop the dot on that day's expansion swing and read the projected vertical lines as timing windows — moments to watch for reactions, rather than price levels. Built for the 5-minute chart. Anchor lines are orange, projected zones blue, each labeled with its multiple/ratio; colors, width, line style, and zone count are all configurable.

## Source Code

````pine
//@version=6
// =============================================================================
// Terminator Harmony  (Fib Time Zones - v5, click-to-place anchor)
// You CLICK the swing that starts the expansion (Anchor 1). The indicator auto-drops
// Anchor 0 on the starting point at/before it (00:00 ET, Globex 18:00 ET, or a settlement
// time: Forex 15:00 / Index 16:00 / Metals 13:30 ET), base = A1 - A0, casts
// the time zones forward: A0 + k*base - Equal steps (default) / Fibonacci sequence /
// Fib ratios (anchors 0 & 1 + standard extensions 1.272..11.09, like a fib tool on time) / Custom.
// Anchor 1 is a full-height draggable VERTICAL LINE - grab it ANYWHERE along its height and
// slide it to the swing; the whole projection re-casts live. One click per day. 5-min chart.
//   (To place it: add the indicator, then click the swing low/high on the chart.)
// =============================================================================
indicator("Terminator Harmony", overlay=true, max_lines_count=500, max_labels_count=500)

// ---------------- the one input you set: drag the Anchor 1 vertical line ----------------
// LONE input.time (no paired price) -> TV renders a whole draggable vertical line, not a tiny dot.
a1in = input.time(timestamp("2026-08-19T02:10:00-04:00"), "Anchor 1 - DRAG the vertical line to the expansion swing", confirm=true)

openMode = input.string("Midnight (00:00 ET)", "Day open (Anchor 0)", options=["Midnight (00:00 ET)", "Globex (18:00 ET)", "Forex settlement (15:00 ET)", "Index settlement (16:00 ET)", "Metals settlement (13:30 ET)"], group="Projection")
mode     = input.string("Equal steps", "Projection mode", options=["Equal steps", "Fibonacci sequence", "Fib ratios", "Custom"], group="Projection")
numZones = input.int(8, "Number of zones forward", minval=1, maxval=40, group="Projection")
customCsv= input.string("1,2,3,5,8,13,21", "Custom multiples (comma-sep)", group="Projection")
colLine  = input.color(color.new(color.blue, 0),   "Zone line", group="Style")
colAnc   = input.color(color.new(color.orange, 0), "Anchor 0 / 1 line", group="Style")
lineWid  = input.int(1, "Line width", minval=1, group="Style")
lineSty  = input.string("Dotted", "Line style", options=["Solid", "Dashed", "Dotted"], group="Style")
showLbl  = input.bool(true, "Show zone numbers", group="Style")
showTime = input.bool(true, "Show clock time on labels (ET)", group="Style")
lblPos   = input.string("Top", "Zone label position", options=["Top", "Bottom"], group="Style")

ny = "America/New_York"

// pane-edge anchors so labels sit clear of the candles (computed every bar for a valid buffer)
float hiN = ta.highest(high, 300)
float loN = ta.lowest(low, 300)
float pad = (hiN - loN) * 0.02

// ---------------- anchors ----------------
// Anchor 0 = the chosen day-open at/before Anchor 1: midnight, Globex 18:00,
// or a settlement time (Forex 15:00 / Index 16:00 / Metals 13:30 ET). Every option
// takes the most-recent HH:MM ET at/before Anchor 1 (rolls back a day if needed).
f_openAt(int hh, int mm) =>
    int t = timestamp(ny, year(a1in, ny), month(a1in, ny), dayofmonth(a1in, ny), hh, mm)
    if a1in < t
        int pv = a1in - 86400000
        t := timestamp(ny, year(pv, ny), month(pv, ny), dayofmonth(pv, ny), hh, mm)
    t
int ohh = openMode == "Globex (18:00 ET)" ? 18 : openMode == "Forex settlement (15:00 ET)" ? 15 : openMode == "Index settlement (16:00 ET)" ? 16 : openMode == "Metals settlement (13:30 ET)" ? 13 : 0
int omm = openMode == "Metals settlement (13:30 ET)" ? 30 : 0
int a0 = f_openAt(ohh, omm)
int a1 = a1in
int base = a1 - a0

f_style() => lineSty == "Solid" ? line.style_solid : lineSty == "Dashed" ? line.style_dashed : line.style_dotted

// ---------------- multiples for the chosen mode ----------------
f_mults() =>
    a = array.new_float()
    if mode == "Fib ratios"
        // anchors 0 (open) & 1.0 (swing) + standard fib EXTENSIONS past 1.0;
        // continues through the golden powers (phi^4=6.854, phi^5=11.09) to span the day
        array.push(a, 0.0)
        array.push(a, 1.0)
        for r in array.from(1.272, 1.618, 2.0, 2.618, 3.618, 4.236, 6.854, 11.09)
            array.push(a, r)
    else
        array.push(a, 0.0)
        if mode == "Equal steps"
            for i = 1 to numZones
                array.push(a, i)
        else if mode == "Fibonacci sequence"
            array.push(a, 1.0)
            array.push(a, 2.0)
            float p1 = 1.0
            float p2 = 2.0
            for i = 3 to numZones
                float n = p1 + p2
                array.push(a, n)
                p1 := p2
                p2 := n
        else
            for s in str.split(customCsv, ",")
                float v = str.tonumber(s)
                if not na(v)
                    array.push(a, v)
    a

// ---------------- draw once on the last bar; re-cast when you drag the anchor ----------------
var array<line>  vlines = array.new<line>()
var array<label> vlabs  = array.new<label>()

if barstate.islast and base > 0
    for ln in vlines
        line.delete(ln)
    for lb in vlabs
        label.delete(lb)
    array.clear(vlines)
    array.clear(vlabs)
    mults = f_mults()
    for m in mults
        int t = a0 + int(m * base)
        color c = (m == 0 or m == 1) ? colAnc : colLine
        // draw a visible line at every zone incl. Anchor 1 (m==1); the native input.time drag
        // handle sits underneath and stays grabbable (standard anchored-indicator pattern)
        line ln = line.new(t, close, t, close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = c, width = lineWid, style = f_style())
        array.push(vlines, ln)
        if showLbl
            string txt = showTime ? str.tostring(m, "#.###") + "\n" + str.format_time(t, "HH:mm", ny) : str.tostring(m, "#.###")
            float ly   = lblPos == "Top" ? hiN + pad : loN - pad
            // borderless text (no plate/outline); text tinted to its line color
            label lb = label.new(t, ly, txt, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = c, size = size.small)
            array.push(vlabs, lb)
````

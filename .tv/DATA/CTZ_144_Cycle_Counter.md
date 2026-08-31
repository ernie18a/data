<!-- tradingview-pine-id: PUB;e16c39f6dc94480ea24ad52a447d77d6 -->
<!-- tradingviewscripts-format: 1 -->
# CTZ 144 Cycle Counter

Source: https://www.tradingview.com/script/N3f0nCa3-CTZ-144-Cycle-Counter/

## Description

Here's a description that leans into the Fibonacci-time angle and positions it as a timing overlay to pair with your other tools.

---

**CTZ 144 Cycle Counter**

144 isn't a random number — it's the twelfth Fibonacci number (…55, 89, **144**, 233…), and the same sequence that governs price also tends to govern *time*. Markets don't just retrace by Fibonacci ratios; they turn on Fibonacci counts. This tool takes that idea and builds a clean, rhythmic time grid across your chart.

**What it does**

Anchored to Bitcoin's last bear market bottom (21 Nov 2022 by default, fully adjustable), it counts forward in blocks of 144 bars and drops a vertical line at every boundary — C1, C2, C3, and so on. Each 144-bar window closes and a new one opens, marking a point in time where the market has historically been prone to a shift. A dashed half-cycle line at bar 72 marks the midpoint, where the internal high often forms. Dotted projection lines extend the rhythm into the future, so you can see the next turning windows *before* price gets there.

**Why time, not just price**

Most indicators react to what price has already done. This one is anchored to the clock instead — the count advances the same way whether the market is trending, ranging, or reversing. Because a 144-bar cadence produces a turning window with real regularity, there's almost always a high or a low landing somewhere near each boundary. That's the point: it's not trying to call the direction, it's telling you *when* to pay attention.

**Timeframe-native**

The count follows whatever chart you load it on. On the daily it's a 144-day rhythm; on the 4H it's 144 four-hour blocks; on the weekly, 144 weeks. Same Fibonacci cadence, scaled to your view — so you can run a macro 144-week grid and a tactical 144-hour grid side by side.

**Built to combine**

This is a timing layer, not a signal system on its own — and that's its strength. A momentum trigger, a cycle-low detector, or a support/resistance level means far more when it fires *inside* a 144 turn window than in dead space mid-cycle. Use the boundaries as a confluence filter: when your entry indicator lines up with a 144 count, the timing and the trigger are agreeing. The counter table keeps you oriented at a glance — which cycle you're in, how many bars deep, and a yellow warning as you enter the turn zone.

*The rhythm tells you when. Your other tools tell you what. Together they tell you whether to act.*

*For educational purposes. Not financial advice — always confirm with your own analysis and test on your own instruments before trading live.*

---

## Source Code

````pine
//@version=6
indicator("CTZ 144 Cycle Counter", shorttitle="CTZ 144", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
grp = "144 Cycle"
anchorTime = input.time(timestamp("21 Nov 2022 00:00"), "Anchor (bear market bottom)", group=grp,
     tooltip="Default = BTC 2022 bottom, 21 Nov 2022. Bars are counted forward from here.")
cycleLen   = input.int(144, "Cycle Length (bars)", minval=2, group=grp)
projFwd    = input.int(4, "Project Forward (cycles)", minval=0, maxval=20, group=grp)
showMid    = input.bool(true, "Mark Half-Cycle (72)", group=grp)

grpS = "Style"
lineCol   = input.color(color.new(#f59e0b, 0),  "Cycle Boundary Colour", group=grpS)
midCol    = input.color(color.new(#3b82f6, 40), "Half-Cycle Colour",     group=grpS)
projCol   = input.color(color.new(#f59e0b, 55), "Projection Colour",     group=grpS)
showCount = input.bool(true, "Show Bar-in-Cycle Label", group=grpS)
showTable = input.bool(true, "Show Counter Table",       group=grpS)

// ── ANCHOR CAPTURE ─────────────────────────────────────────────
var int anchorBar = na
if na(anchorBar) and time >= anchorTime
    anchorBar := bar_index

barsSince = na(anchorBar) ? na : bar_index - anchorBar
cyclePos  = na(barsSince) ? na : barsSince % cycleLen          // 0..cycleLen-1
cycleNum  = na(barsSince) ? na : math.floor(barsSince / cycleLen) + 1
isBoundary = not na(cyclePos) and cyclePos == 0 and barsSince >= 0
isMid      = not na(cyclePos) and showMid and cyclePos == math.round(cycleLen / 2.0)

// ── HISTORICAL BOUNDARY LINES ──────────────────────────────────
if isBoundary
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index,
         extend=extend.both, color=lineCol, width=1, style=line.style_solid)
    if showCount
        label.new(bar_index, high, "C" + str.tostring(cycleNum),
             yloc=yloc.abovebar, style=label.style_label_down,
             color=color.new(lineCol, 20), textcolor=color.white, size=size.small)

if isMid
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index,
         extend=extend.both, color=midCol, width=1, style=line.style_dashed)

// ── FORWARD PROJECTION (drawn once, on the last bar) ───────────
var array<line>  projLines = array.new<line>()
var array<label> projLabs  = array.new<label>()

if barstate.islast and not na(anchorBar)
    for ln in projLines
        line.delete(ln)
    for lb in projLabs
        label.delete(lb)
    array.clear(projLines)
    array.clear(projLabs)

    int nextBoundaryOffset = cyclePos == 0 ? 0 : cycleLen - cyclePos
    int baseCycle = cycleNum
    int maxFwd = 499   // TradingView caps future bar_index objects at 500

    for i = 0 to projFwd - 1
        int bx = bar_index + nextBoundaryOffset + i * cycleLen
        if bx - bar_index <= maxFwd
            line pl = line.new(bx, low, bx, high, xloc=xloc.bar_index,
                 extend=extend.both, color=projCol, width=1, style=line.style_dotted)
            array.push(projLines, pl)
            label plb = label.new(bx, high, "C" + str.tostring(baseCycle + i + 1) + " →",
                 xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down,
                 color=color.new(projCol, 20), textcolor=color.white, size=size.small)
            array.push(projLabs, plb)

            if showMid
                int mx = bx - math.round(cycleLen / 2.0)
                if mx > bar_index and mx - bar_index <= maxFwd
                    line ml = line.new(mx, low, mx, high, xloc=xloc.bar_index,
                         extend=extend.both, color=midCol, width=1, style=line.style_dashed)
                    array.push(projLines, ml)

// ── COUNTER TABLE ──────────────────────────────────────────────
var table t = na
if showTable and barstate.islast
    if na(t)
        t := table.new(position.top_right, 2, 4,
             bgcolor=color.new(#0a0f1e, 10), border_width=1,
             border_color=color.new(color.white, 75))
    table.cell(t, 0, 0, "144 CYCLE", bgcolor=color.new(#14532d, 0),
         text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 0, str.tostring(cycleLen) + " bars", bgcolor=color.new(#14532d, 0),
         text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1, "Cycle #", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(t, 1, 1, na(cycleNum) ? "–" : str.tostring(cycleNum), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Bar in cycle", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(t, 1, 2, na(cyclePos) ? "–" : str.tostring(cyclePos) + " / " + str.tostring(cycleLen),
         text_color=cyclePos <= 7 or cyclePos >= cycleLen - 7 ? color.yellow : color.white, text_size=size.small)
    table.cell(t, 0, 3, "Total bars", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(t, 1, 3, na(barsSince) ? "–" : str.tostring(barsSince), text_color=color.white, text_size=size.small)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(isBoundary, "144 Cycle Boundary", "CTZ 144: new cycle boundary — {{ticker}}")
alertcondition(isMid,      "144 Half-Cycle",     "CTZ 144: half-cycle (72) — {{ticker}}")
````

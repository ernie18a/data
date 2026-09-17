<!-- tradingview-pine-id: PUB;c57c7214100c4ced844555296a8d6fd9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Buyer/Seller Zones — where orders are sitting

Source: https://www.tradingview.com/script/P9z3T752-OTT-Rejection-Zone/

## Description

OTT Rejection Zone is a chart overlay for decision-making. Its purpose is to help you answer three questions before you take a trade:

[*]Where are the orders? (Zones)
[*]How proven is each level? (Touch count)
[*]Which side is advancing right now? (Pressure lines)

What you see on the chart

1) The Boxes = "Buyer / Seller Zones"

Red zones form where sellers have repeatedly rejected price from above. Green zones form where buyers have repeatedly defended from below. A zone is only drawn after a level has been defended at least twice one-off swings don't qualify. Zone width scales with ATR, so the zones mean the same thing on any symbol and any timeframe.

How to use it

- Price approaching a red zone → expect supply; watch how price reacts, not just that it arrived.
- Price approaching a green zone → expect demand; same rule.
- A zone disappearing → price closed decisively through it; the defenders are gone. Don't expect a level to matter after it's been broken.

Simple mental model

- Zone = where orders have proven themselves
- No zone = price is in open water

2) The Number on Each Zone = "Touch Count"

Every zone shows how many separate times it has been defended for example, SELLERS x4. Touches include wick-tests: any candle that pushes into the zone and closes rejected adds to the count (with a small cooldown so one cluster of candles isn't over-counted).

How to use it

- x2 → a young level, lightly proven.
- x3–x4 → a real shelf; both sides know it's there.
- A count that keeps climbing while the zone holds → active defense, orders still there.

One caution: a heavily tested level is well-proven but also well-worn levels don't hold forever, and the break of a many-touch zone tends to travel.

3) Solid vs Faded Zones = "Hot / Cold"

Zones defended within the last 30 candles render solid that's live inventory. Zones that haven't been tested recently fade but remain valid.

How to use it

- Solid zone → participants are actively engaged there right now.
- Faded zone → still a reference level, but treat it as memory rather than presence.

4) The Dotted Lines = "Pressure Lines"

When three or more minor swing highs step down in a row, a dotted red line is drawn through them and extended forward: sellers accepting worse prices to get filled — which only happens when they're eager. The mirror in green: rising lows = buyers pressing. The line invalidates the moment price closes through it.

How to use it

- Falling red line into a red zone above → sellers are both positioned and advancing. The strongest bearish picture this tool draws.
- A pressure line breaking → the advance has paused; the side that was pressing just lost initiative.

Simple mental model

- Zone = where they sit
- Pressure line = they're walking toward you

How a beginner can use this (step-by-step)

Step 1 — Find the nearest zones. Above and below current price. That's your map.

Step 2 — Read the counts and shading. Solid, high-count zones deserve the most respect.

Step 3 — Check for a pressure line. If one side is pressing toward a zone, plan around that side keeping the initiative until the line breaks.

Step 4 — Let the reaction be your trigger. This tool tells you where the decision areas are you enter only on your own trigger at those areas (rejection candle, structure reclaim, session timing). The zones are the location, not the signal.

Settings

Swing strength (5) controls zone granularity higher gives fewer, more major levels. Minor swing strength (2) sets pressure-line sensitivity. Zone half-width (0.25 ATR) and break-through distance (0.5 ATR) are ATR-based so behavior is consistent across markets. Touches to draw (2) hides unproven swings; the 30-candle activity window separates hot from cold; the 3-bar cooldown prevents over-counting. Enable "Keep broken zones" to study break-and-retest behavior on faded boxes.

Limitations

Zones and lines appear only after a swing confirms (swing strength × bars later). This delay is deliberate  nothing repaints retroactively but it means levels form with a lag rather than at the exact turn. Pressure lines are deleted and redrawn as new swings confirm. Everything here is inferred from price behavior: it shows where orders were defended, not a live order book, and a level having held before is never a guarantee it holds again.
 OTT Rejection Zone is a chart overlay for decision-making. Its purpose is to help you answer three questions before you take a trade:

  Where are the orders? (Zones)
  How proven is each level? (Touch count)
  Which side is advancing right now? (Pressure lines)

  What you see on the chart

  1) The Boxes = "Buyer / Seller Zones"

  Red zones form where sellers have repeatedly rejected price from above. Green zones form where buyers have repeatedly defended from below. A zone is only drawn after a level has been defended at least twice one-off swings don't qualify. Zone width scales with ATR, so the zones mean the same thing on any symbol and any timeframe.

  How to use it

  - Price approaching a red zone → expect supply; watch how price reacts, not just that it arrived.
  - Price approaching a green zone → expect demand; same rule.
  - A zone disappearing → price closed decisively through it; the defenders are gone. Don't expect a level to matter after it's been broken.

  Simple mental model

  - Zone = where orders have proven themselves
  - No zone = price is in open water

  2) The Number on Each Zone = "Touch Count"

  Every zone shows how many separate times it has been defended  for example, SELLERS x4. Touches include wick-tests: any candle that pushes into the zone and closes rejected adds to the count (with a small cooldown so one cluster of candles isn't over-counted).

  How to use it

  - x2 → a young level, lightly proven.
  - x3–x4 → a real shelf; both sides know it's there.
  - A count that keeps climbing while the zone holds → active defense, orders still there.

  One caution: a heavily tested level is well-proven but also well-worn levels don't hold forever, and the break of a many-touch zone tends to travel.

  3) Solid vs Faded Zones = "Hot / Cold"

  Zones defended within the last 30 candles render solid that's live inventory. Zones that haven't been tested recently fade but remain valid.

  How to use it

  - Solid zone → participants are actively engaged there right now.
  - Faded zone → still a reference level, but treat it as memory rather than presence.

---

## Source Code

````pine
//@version=6
indicator("Buyer/Seller Zones — where orders are sitting", overlay=true,
     max_boxes_count=250, max_labels_count=250)

// ---------------- inputs ----------------
pivLen    = input.int(10,    "Pivot strength (bars each side)", 3, 50)
tolMult   = input.float(0.25,"Zone half-width (ATR mult)", 0.05, 1.0, 0.05)
minTouch  = input.int(2,     "Touches needed to draw a zone", 2, 10)
breakMult = input.float(0.5, "Break-through distance (ATR mult)", 0.1, 2.0, 0.1)
atrLen    = input.int(14,    "ATR length")
maxZones  = input.int(8,     "Max live zones per side", 2, 20)
keepDead  = input.bool(false,"Keep broken zones (faded)")

a = ta.atr(atrLen)

// ---------------- level books (parallel arrays) ----------------
var float[] sPx  = array.new_float()   // seller levels (from swing highs)
var int[]   sN   = array.new_int()
var int[]   sBar = array.new_int()
var box[]   sBx  = array.new_box()
var float[] bPx  = array.new_float()   // buyer levels (from swing lows)
var int[]   bN   = array.new_int()
var int[]   bBar = array.new_int()
var box[]   bBx  = array.new_box()

zoneCol(bool isSell, bool dead) =>
    base = isSell ? color.red : color.green
    color.new(base, dead ? 94 : 85)

// merge a fresh pivot into a book, or open a new level
processPivot(float px, int pbar, float[] arrPx, int[] arrN, int[] arrBar, box[] arrBx, bool isSell) =>
    tol = tolMult * a
    mergedAt = -1
    sz = array.size(arrPx)
    if sz > 0
        for i = 0 to sz - 1
            if mergedAt < 0 and math.abs(array.get(arrPx, i) - px) <= tol
                mergedAt := i
    if mergedAt >= 0
        cnt = array.get(arrN, mergedAt) + 1
        avg = (array.get(arrPx, mergedAt) * array.get(arrN, mergedAt) + px) / cnt
        array.set(arrPx, mergedAt, avg)
        array.set(arrN, mergedAt, cnt)
        bx = array.get(arrBx, mergedAt)
        if cnt >= minTouch and na(bx)
            bx := box.new(array.get(arrBar, mergedAt), avg + tol, bar_index, avg - tol,
                 border_color=zoneCol(isSell, false), bgcolor=zoneCol(isSell, false))
            array.set(arrBx, mergedAt, bx)
        if not na(bx)
            box.set_top(bx, avg + tol)
            box.set_bottom(bx, avg - tol)
            box.set_text(bx, (isSell ? "SELLERS x" : "BUYERS x") + str.tostring(cnt))
            box.set_text_color(bx, isSell ? color.red : color.green)
            box.set_text_size(bx, size.small)
    if mergedAt < 0
        array.push(arrPx, px)
        array.push(arrN, 1)
        array.push(arrBar, pbar)
        array.push(arrBx, box(na))
        if array.size(arrPx) > maxZones          // retire the oldest level
            oldBx = array.shift(arrBx)
            if not na(oldBx)
                box.delete(oldBx)
            dropF = array.shift(arrPx)
            dropN = array.shift(arrN)
            dropB = array.shift(arrBar)
    true

// a level dies when price CLOSES decisively through it
sweepDead(float[] arrPx, int[] arrN, int[] arrBar, box[] arrBx, bool isSell) =>
    i = 0
    while i < array.size(arrPx)
        lvl = array.get(arrPx, i)
        bx = array.get(arrBx, i)
        broke = isSell ? close > lvl + breakMult * a : close < lvl - breakMult * a
        if broke and not na(bx)
            if keepDead
                box.set_bgcolor(bx, zoneCol(isSell, true))
                box.set_border_color(bx, zoneCol(isSell, true))
            else
                box.delete(bx)
        if broke
            dropF = array.remove(arrPx, i)
            dropN = array.remove(arrN, i)
            dropB = array.remove(arrBar, i)
            dropX = array.remove(arrBx, i)
        if not broke
            if not na(bx)
                box.set_right(bx, bar_index)     // live zones extend with time
            i += 1
    true

// ---------------- engine ----------------
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
if not na(ph)
    processPivot(ph, bar_index - pivLen, sPx, sN, sBar, sBx, true)
if not na(pl)
    processPivot(pl, bar_index - pivLen, bPx, bN, bBar, bBx, false)
sweepDead(sPx, sN, sBar, sBx, true)
sweepDead(bPx, bN, bBar, bBx, false)
````

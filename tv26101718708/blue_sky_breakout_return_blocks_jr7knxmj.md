# Blue Sky Breakout - Return Blocks

- url: https://www.tradingview.com/script/JR7kNxmj-Blue-Sky-Breakout-Return-Blocks/
- type: indicator
- pine_id: PUB;a480400cd62441b0b4699c1570a34184
- version: 1.0

## Description

WHAT IT DOES

A return over three, six, nine or twelve months is a single number, and a
column of such numbers hides the one thing that matters: where in that year
the move actually happened. This indicator draws it.

The last twelve months of the chart are cut into four blocks, one per
period: twelve to nine months back, nine to six, six to three, and the last
three months. Each block is filled with the colour of its own figure, green
when that return is positive, red when it is negative, and the stronger the
move, the deeper the fill.

Over the blocks runs a fan. One dashed ray per period, drawn from the close
on that period's start date to the close today, plus a fifth ray over three
years. Because all rays end in the same candle, the picture says what the
numbers mean: each figure is measured from a day in the past to now, not
inside its block. A steep ray carries a lot of the move in little time, a
flat one carries little.

The table in the corner shows the same five figures as text: 3M, 6M, 9M,
12M and 3Y.

HOW TO READ IT

Blocks growing lighter towards the right: the move is older, the last
quarter added little. A deep block on the right: the move is recent. Red on
the left, green on the right: down over the year, turned in the last months.
Rays that lie almost on top of each other: a steady move. Rays that spread
wide apart: one period did most of the work.

ORIGINALITY

Multi period returns are normally read as a list, in a screener column or a
table under the chart. Plotting each period as a block on the candles, and
each figure as a ray that converges in today's price, puts the size of the
move and its timing into one picture, and it makes a common misreading
visible: a weak three month figure next to a strong twelve month figure is
not a contradiction, it is a shorter window ending on the same day. I have
not found this combination in a published script, which is why this is a
separate publication and not a variation of an existing one.

SETTINGS

Blocks: coloured background on or off, its strength, divider every three
months. Fan: rays on or off, a label per ray, three year ray on or off.
Table: on or off and which of the four corners.

CALCULATION AND LIMITS

Returns over 63, 126, 189, 252 and 756 bars, which is about three, six, nine
and twelve months and three years of trading days. Built for daily candles:
on any other timeframe the windows still count bars, not months. A symbol
with fewer than 252 bars of history draws nothing, and the three year ray
needs 756 bars.

Everything is drawn on the most recent bar, so no mark ever sits on a
historical bar and nothing can be redrawn later. The blocks deliberately
reach far above and below the price: drawing objects are ignored by the axis
scaling, which is what lets a full height background exist without
squeezing the chart.

ALERTS

Two conditions, both on the sign of the twelve month return: turned positive
and turned negative.

WHAT IT IS NOT

A measuring tool, not advice. No entries, no exits, no targets, no forecast.
Every colour and every figure is a measured past. Past performance is not a
reliable indicator of future results, and trading stocks can cost you
everything you put in.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6

// Blue Sky Breakout Return Blocks  |  build 2026-09-24
//
// Colour blocks and a fan of returns: 3M, 6M, 9M, 12M and 3 years, each
// one measured from today backwards. Green when the return is positive,
// red when it is negative, deeper the stronger the move.
//
// Every colour is a measured past, never a forecast. This script gives
// no advice: no entries, no exits, no targets. Trading stocks can cost
// you everything you put in.

indicator("Blue Sky Breakout Return Blocks", shorttitle = "BSB Return Blocks", overlay = true,
     max_boxes_count = 12, max_lines_count = 20, max_labels_count = 20, max_polylines_count = 12)

// ── Settings ─────────────────────────────────────────────────────────
gBlocks = "Blocks"
showArea = input.bool(true, "Coloured background for the last 12 months", group = gBlocks)
showDividers = input.bool(true, "Divider every three months", group = gBlocks)
areaStrength = input.float(0.32, "Background strength", minval = 0.05, maxval = 1.0, step = 0.02, group = gBlocks,
     tooltip = "How strongly the blocks are tinted. Lower keeps the candles easier to read.")

gFan = "Fan"
showFan = input.bool(true, "Fan: one ray per column, start to today", group = gFan)
showFanLabels = input.bool(true, "Label each ray with its return", group = gFan)
showThreeYear = input.bool(true, "Include the three year ray", group = gFan)

gTable = "Table"
showTable = input.bool(true, "Show the figures table", group = gTable)
tablePos = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gTable)

// Every symbol, no limit.
allowed = true

// ── The returns, the columns of the table ────────────────────────────
perf(len) =>
    base = close[len]
    na(base) or base == 0 ? na : (close / base - 1) * 100

p3  = perf(63)
p6  = perf(126)
p9  = perf(189)
p12 = perf(252)
p36 = perf(756)

// ── Colours ──────────────────────────────────────────────────────────
tone(v) =>
    mag = math.abs(v)
    na(v) ? color.gray
         : v >= 0
             ? (mag < 20 ? #86efac : mag < 60 ? #22c55e : #15803d)
             : (mag < 20 ? #fca5a5 : mag < 60 ? #ef4444 : #b91c1c)

area(v) =>
    grade = (math.min(math.abs(v) / 60, 0.70) + 0.06) * areaStrength
    na(v) ? color.new(color.gray, 100)
         : (v >= 0 ? color.rgb(34, 197, 94, math.round((1 - grade) * 100))
                   : color.rgb(239, 68, 68, math.round((1 - grade) * 100)))

plus(v) => v >= 0 ? "+" : "-"
pct(x) => na(x) ? "-" : plus(x) + str.tostring(math.round(math.abs(x))) + " %"

// ── Everything is drawn on the LAST candle ───────────────────────────
// A historical bar cannot know today's return, so blocks, dividers,
// labels and rays are drawing objects that start at the right edge and
// reach back to the left.
if allowed and barstate.islast and bar_index > 252
    // Blocks and dividers fill the whole height. Drawing objects are not
    // part of the axis scaling, so the frame may reach far past the price
    // without squeezing the chart.
    span = math.min(bar_index, 1000)
    hiEdge = ta.highest(high, span) * 20
    loEdge = math.max(ta.lowest(low, span) / 20, syminfo.mintick)

    vals = array.from(p12, p9, p6, p3)
    tags = array.from("12M", "9M", "6M", "3M")
    back = array.from(252, 189, 126, 63)

    for j = 0 to 3
        v = array.get(vals, j)
        startIdx = bar_index - array.get(back, j)
        endIdx = j < 3 ? bar_index - array.get(back, j + 1) : bar_index

        if not na(v)
            if showArea
                box.new(startIdx, hiEdge, endIdx, loEdge, border_width = 0, bgcolor = area(v))

            if showDividers and j > 0
                line.new(startIdx, loEdge, startIdx, hiEdge, color = color.new(color.gray, 55),
                     style = line.style_dashed, width = 1)

    if showFan
        for j = 0 to 3
            v = array.get(vals, j)
            days = array.get(back, j)

            if not na(v)
                line.new(bar_index - days, close[days], bar_index, close,
                     color = tone(v), style = line.style_dashed, width = 2)

                if showFanLabels
                    label.new(bar_index - days, close[days],
                         array.get(tags, j) + " " + pct(v),
                         style = label.style_label_left, color = color.new(color.white, 20),
                         textcolor = tone(v), size = size.small)

        if showThreeYear and not na(p36) and bar_index > 756
            line.new(bar_index - 756, close[756], bar_index, close,
                 color = tone(p36), style = line.style_dashed, width = 2)

            if showFanLabels
                label.new(bar_index - 756, close[756], "3Y " + pct(p36),
                     style = label.style_label_left, color = color.new(color.white, 20),
                     textcolor = tone(p36), size = size.small)

    // Arrow head in today's price, where all rays meet
    label.new(bar_index, close, "", style = label.style_arrowup,
         color = color.new(#0f172a, 20), size = size.tiny)

// ── Table ────────────────────────────────────────────────────────────
place = switch tablePos
    "Top right" => position.top_right
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left

var table tbl = table.new(place, 2, 6, border_width = 1, border_color = color.new(color.gray, 60))
dark = color.new(color.black, 70)
blue = color.new(#2563EB, 0)

if barstate.islast and showTable
    table.cell(tbl, 0, 0, "Blue Sky Breakout", text_color = color.white, bgcolor = blue, text_size = size.normal)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color = color.white, bgcolor = blue, text_size = size.normal)

    table.cell(tbl, 0, 1, "3M", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 1, pct(p3), text_color = color.white, bgcolor = tone(p3), text_size = size.small)
    table.cell(tbl, 0, 2, "6M", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 2, pct(p6), text_color = color.white, bgcolor = tone(p6), text_size = size.small)
    table.cell(tbl, 0, 3, "9M", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 3, pct(p9), text_color = color.white, bgcolor = tone(p9), text_size = size.small)
    table.cell(tbl, 0, 4, "12M", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 4, pct(p12), text_color = color.white, bgcolor = tone(p12), text_size = size.small)
    table.cell(tbl, 0, 5, "3Y", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 5, pct(p36), text_color = color.white, bgcolor = tone(p36), text_size = size.small)

// ── Alerts on the sign change of the twelve month return ─────────────
wasUp = not na(p12[1]) and p12[1] >= 0
isUp = not na(p12) and p12 >= 0

alertcondition(allowed and isUp and not wasUp, title = "12 months turned positive", message = "{{ticker}}: twelve month return turned positive (Blue Sky Breakout).")
alertcondition(allowed and wasUp and not isUp, title = "12 months turned negative", message = "{{ticker}}: twelve month return turned negative (Blue Sky Breakout).")
````

# Opening Gap [ITA]

- url: https://www.tradingview.com/script/J0X1EWzq-Opening-Gap-ITA/
- type: indicator
- pine_id: PUB;2fc664db166642ba81781fe09b0b2717
- version: 1.0

## Description

🟠 OVERVIEW

Opening Gap draws the distance between yesterday's close and today's open, keeps the level that has to be reached for the gap to be filled, and counts two separate things: how often the gap filled on the same day, and how often it filled at all within a window you set.

Gaps always fill is one of the oldest sentences in trading and one of the least often checked. Filling eventually is close to meaningless, because given enough time price revisits almost any level. Filling on the same day is a statement you can trade. Both rates sit in the corner, side by side, so the difference between them is visible rather than assumed.

🟠 CONCEPTS

* Opening Gap - The session opening away from the previous session's close.
* The Level - Yesterday's close. A gap is filled when price trades back to that level, not when it enters the shaded zone.
* Filled Same Day - Price reached the level before the session ended.
* Filled Late - It reached the level on a later day, inside the window.
* Unfilled - The window passed without the level being reached. It stays in the count.

🟠 HOW IT WORKS

At each new daily session the open is compared with the previous close. A difference larger than the threshold opens a gap, drawn as a zone with a dotted line at the level that fills it.

From then on every bar is checked. A gap up fills when price trades down to yesterday's close, a gap down when price trades up to it. The first fill is recorded as same day or late depending on whether the session it opened in has ended.

A gap that reaches the end of its window unfilled stops being watched and its drawing is removed, but it remains in the denominator. Removing it would turn the fill rate into a measure of how long the window is.

🟠 SETTINGS

* Smallest Gap - As a multiple of the daily ATR. At zero, a one tick difference counts as a gap, which is most mornings.
* Days Allowed For The Later Fill - The window for the second count. The same-day count is unaffected by it.
* Track - Gap ups, gap downs, or both. The two behave differently on many symbols and separating them is often the point.
* Keep Filled Zones On Chart - Off, what is left on the chart is only what is still open.

🟠 NOTES

Works on daily and intraday. On an intraday chart the gap appears at the session open and the same-day count has room to resolve inside that session. On a daily chart the whole session is one bar, so a same-day fill is a bar that traded back through the level.

The rates belong to the symbol on screen. A market that gaps on news behaves nothing like one that gaps on a dividend, and the number is worth reading on several symbols before it means anything.

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
// =============================================================================
// Opening Gap [ITA]
//
// "Gaps always fill" is one of the oldest sentences in trading and one of the
// least often checked. Every tool in this category draws the gap between
// yesterday's close and today's open, shades it, and leaves the claim sitting
// there unexamined.
//
// This one checks it, and it separates the two questions that get mixed into
// one. Filling eventually is nearly meaningless, because given enough time
// price revisits almost any level. Filling on the same day is a tradeable
// statement. Both rates are counted for the symbol on screen and sit in the
// corner, side by side, so the difference between them is visible.
//
// The gap level is yesterday's close. It is filled when price trades back to
// that level, not when it merely enters the shaded area.
// =============================================================================

indicator("Opening Gap [ITA]", overlay = true,
     max_boxes_count = 200, max_labels_count = 300, max_lines_count = 200)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
grpDetect  = "Detection"
// Measured on QQQ daily: at 0.2 the script counted 3,762 gaps, which is very
// nearly every bar in the history. A threshold that passes every day is not a
// threshold, and the word gap stops meaning anything. Half a daily ATR is the
// point where what is left looks like what a trader would call a gap.
minGapAtr  = input.float(0.5, "Smallest Gap (x ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = grpDetect,
     tooltip = "Ignore gaps smaller than this multiple of the daily ATR. Low values count almost every session as a gap: on QQQ daily, 0.2 passes nearly every bar in the history.")
maxDays    = input.int(10, "Days Allowed For The Later Fill", minval = 1, maxval = 120, group = grpDetect,
     tooltip = "How long a gap stays under observation for the second count. The same-day count is unaffected by this.")
gapDir     = input.string("Both", "Track", options = ["Both", "Gap up only", "Gap down only"], group = grpDetect)

grpShow    = "Display"
showZone   = input.bool(true, "Draw The Gap Zone", group = grpShow)
showLevel  = input.bool(true, "Draw Yesterday's Close", group = grpShow)
showMarks  = input.bool(true, "Mark Filled", group = grpShow)
showStats  = input.bool(true, "Show The Count", group = grpShow)
keepFilled = input.bool(false, "Keep Filled Zones On Chart", group = grpShow,
     tooltip = "Off, a zone is removed the moment it fills, so what is left on the chart is only what is still open.")
maxDraw    = input.int(10, "Most Recent Gaps To Draw", minval = 1, maxval = 200, group = grpShow,
     tooltip = "Applies to the drawings only. Every gap is counted whatever this is set to.")
// Same control as the Fair Value Gap Screener, and here for the same reason.
// An unfilled gap kept extending to the current bar, which on a daily chart is
// a few bars wide and on fifteen minutes is a block across half the screen.
maxLen     = input.int(60, "Longest A Zone Is Drawn (bars)", minval = 5, maxval = 2000, group = grpShow,
     tooltip = "A zone stops extending after this many bars even if the gap is still open. It is still being watched and still counted, it is just no longer drawn across the chart.")
statPos    = input.string("Top Right", "Count Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpShow)
statSizeStr = input.string("Normal", "Count Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpShow)
lblSizeStr  = input.string("Small", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpShow)
// Anchored exactly on the level, the label sits inside the price action and
// the candles run straight through the text. It is pushed away from the fill
// instead: a gap up fills from above, so its label hangs below the level.
lblOffset   = input.float(0.6, "Label Offset (x ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = grpShow,
     tooltip = "How far the Filled labels sit from the level. At zero they sit on it and the candles cover them.")

grpCol  = "Colors"
upCol   = input.color(color.new(#089981, 80), "Gap Up Fill", group = grpCol)
dnCol   = input.color(color.new(#f23645, 80), "Gap Down Fill", group = grpCol)
edgeCol = input.color(color.new(#787b86, 20), "Zone Border", group = grpCol)
lvlCol  = input.color(#e5c56b, "Yesterday's Close", group = grpCol)
fillCol = input.color(#089981, "Filled Mark", group = grpCol)

sizeOf(string s) =>
    r = size.normal
    if s == "Tiny"
        r := size.tiny
    else if s == "Small"
        r := size.small
    else if s == "Large"
        r := size.large
    else if s == "Huge"
        r := size.huge
    r

statSize = sizeOf(statSizeStr)
lblSize  = sizeOf(lblSizeStr)

// ─── STATE ───────────────────────────────────────────────────────────────────
// The daily ATR, asked for on the daily series so the threshold means the same
// thing whether this is read on a daily chart or on five minutes.
atrD = request.security(syminfo.tickerid, "1D", ta.atr(14), lookahead = barmerge.lookahead_off)

// The chart's own ATR, for positioning only. The daily one sets the gap
// threshold and would throw a label far off screen on a five minute chart.
atrC = ta.atr(14)

newDay = timeframe.change("1D")

// Open gaps under observation. Parallel arrays rather than one array of a
// user type, because several gaps can be open at once and each needs its own
// level, direction, age and drawing.
var array<float> gLevel = array.new<float>()
var array<int>   gDir   = array.new<int>()
var array<int>   gDay   = array.new<int>()     // day index when it opened
var array<box>   gBox   = array.new<box>()
var array<line>  gLine  = array.new<line>()
var array<bool>  gSame  = array.new<bool>()    // still inside its first day

// Fill labels are drawn for the recent gaps only. The count keeps every gap,
// but a label for each one buries the chart: the first version wrote one per
// fill with no limit and QQQ daily came out as a wall of the word "Filled".
var array<label> marks  = array.new<label>()

var int dayCount = 0

var int total      = 0
var int filledSame = 0
var int filledLate = 0

if newDay
    dayCount += 1

// ─── A NEW GAP ───────────────────────────────────────────────────────────────
if newDay and not na(close[1]) and not na(atrD)
    diff = open - close[1]
    up   = diff > 0
    big  = math.abs(diff) >= atrD * minGapAtr and math.abs(diff) > 0
    want = gapDir == "Both" or (gapDir == "Gap up only" and up) or (gapDir == "Gap down only" and not up)
    if big and want
        total += 1
        array.push(gLevel, close[1])
        array.push(gDir, up ? 1 : -1)
        array.push(gDay, dayCount)
        array.push(gSame, true)
        if showZone
            b = box.new(bar_index, math.max(open, close[1]), bar_index, math.min(open, close[1]),
                 bgcolor = up ? upCol : dnCol, border_color = edgeCol, border_width = 1)
            array.push(gBox, b)
        else
            array.push(gBox, box(na))
        if showLevel
            l = line.new(bar_index, close[1], bar_index, close[1], color = lvlCol, width = 1,
                 style = line.style_dotted)
            array.push(gLine, l)
        else
            array.push(gLine, line(na))

// ─── FILL AND AGEING ─────────────────────────────────────────────────────────
// Walked backwards so an entry can be removed without disturbing the indices
// of the ones not yet visited.
if array.size(gLevel) > 0
    for i = array.size(gLevel) - 1 to 0
        lvl  = array.get(gLevel, i)
        dir  = array.get(gDir, i)
        born = array.get(gDay, i)
        same = array.get(gSame, i)
        bx   = array.get(gBox, i)
        ln   = array.get(gLine, i)

        // A gap up fills when price trades back down to yesterday's close.
        hit = dir == 1 ? low <= lvl : high >= lvl

        // Stop extending once the zone has run its length. The gap itself
        // stays under observation; only the drawing is capped.
        if not na(bx) and bar_index - box.get_left(bx) < maxLen
            box.set_right(bx, bar_index)
        if not na(ln) and bar_index - line.get_x1(ln) < maxLen
            line.set_x2(ln, bar_index)

        // The first day ends when a new day starts, and the gap's own opening
        // bar is part of it, so the flag is lowered only on a later day.
        if newDay and born < dayCount
            array.set(gSame, i, false)
            same := false

        if hit
            if same
                filledSame += 1
            else
                filledLate += 1
            if showMarks
                mk = label.new(bar_index,
                     dir == 1 ? lvl - atrC * lblOffset : lvl + atrC * lblOffset,
                     same ? "Filled" : "Filled late",
                     style = dir == 1 ? label.style_label_up : label.style_label_down,
                     color = fillCol, textcolor = color.white, size = lblSize)
                array.push(marks, mk)
                if array.size(marks) > maxDraw
                    label.delete(array.shift(marks))
            if not keepFilled
                if not na(bx)
                    box.delete(bx)
                if not na(ln)
                    line.delete(ln)
            array.remove(gLevel, i)
            array.remove(gDir, i)
            array.remove(gDay, i)
            array.remove(gSame, i)
            array.remove(gBox, i)
            array.remove(gLine, i)

        else if dayCount - born >= maxDays
            // Out of time. It stays in the denominator, because a gap that
            // never filled is exactly the case the claim is about, and
            // dropping it would turn the fill rate into a measure of how
            // patient the window is.
            //
            // The drawing follows the same setting as a filled one. The first
            // version deleted it regardless, so a chart with Keep Filled Zones
            // on showed every gap that closed and none of the gaps that never
            // did, which is the wrong half to hide.
            if not keepFilled
                if not na(bx)
                    box.delete(bx)
                if not na(ln)
                    line.delete(ln)
            array.remove(gLevel, i)
            array.remove(gDir, i)
            array.remove(gDay, i)
            array.remove(gSame, i)
            array.remove(gBox, i)
            array.remove(gLine, i)

// Keep only the most recent drawings on screen. The entry itself stays under
// observation: removing it here as well would stop counting a gap that is
// still open, and the rate would quietly become a rate over recent gaps only.
drawn = 0
if array.size(gBox) > 0
    for i = 0 to array.size(gBox) - 1
        if not na(array.get(gBox, i))
            drawn += 1
    if drawn > maxDraw
        toClear = drawn - maxDraw
        for i = 0 to array.size(gBox) - 1
            if toClear <= 0
                break
            b = array.get(gBox, i)
            if not na(b)
                box.delete(b)
                array.set(gBox, i, box(na))
                l = array.get(gLine, i)
                if not na(l)
                    line.delete(l)
                    array.set(gLine, i, line(na))
                toClear -= 1

// ─── THE COUNT ───────────────────────────────────────────────────────────────
resolved = filledSame + filledLate
sameRate = total > 0 ? filledSame / total * 100 : 0.0
anyRate  = total > 0 ? resolved / total * 100 : 0.0

posOf(string s) =>
    r = position.top_right
    if s == "Top Left"
        r := position.top_left
    else if s == "Bottom Right"
        r := position.bottom_right
    else if s == "Bottom Left"
        r := position.bottom_left
    r

var table stats = na
if showStats and barstate.islast
    if na(stats)
        stats := table.new(posOf(statPos), 2, 4, border_width = 1)
    table.cell(stats, 0, 0, "OPENING GAP", text_color = #e5c56b, text_size = statSize)
    table.cell(stats, 1, 0, "", text_size = statSize)
    table.cell(stats, 0, 1, "Gaps", text_color = color.new(color.white, 25), text_size = statSize)
    table.cell(stats, 1, 1, str.tostring(total), text_color = color.white, text_size = statSize)
    table.cell(stats, 0, 2, "Filled same day", text_color = color.new(color.white, 25), text_size = statSize)
    table.cell(stats, 1, 2, total > 0 ? str.tostring(sameRate, "#.#") + "%" : "no data",
         text_color = fillCol, text_size = statSize)
    table.cell(stats, 0, 3, "Within " + str.tostring(maxDays) + " days",
         text_color = color.new(color.white, 25), text_size = statSize)
    table.cell(stats, 1, 3, total > 0 ? str.tostring(anyRate, "#.#") + "%" : "no data",
         text_color = color.white, text_size = statSize)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(newDay and array.size(gLevel) > 0, "New opening gap",
     "The session opened away from yesterday's close.")
````

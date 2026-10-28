# Key Daily Levels by Flip On Dip

- url: https://www.tradingview.com/script/2stEcfCT-Key-Daily-Levels-by-Flip-On-Dip/
- type: indicator
- pine_id: PUB;b0f00bc048c640eebc3590ee65d08da0
- version: 1.0

## Description

Key Daily Levels marks the reference points most intraday traders watch: the previous day high and low, and the high and low of a session you choose.

Sessions cover New York, London, Tokyo and Sydney, plus a custom option for any other window. Each preset uses the session's local exchange hours and adjusts for daylight saving on its own, so the times stay correct through the year instead of drifting an hour twice a year.

When a session extreme sits at the same price as the previous day high or low, the two are combined into one line instead of being drawn twice. The label then reads something like PDH (NY High), so both are kept without doubling up on the chart.

Each level is drawn from the bar where it formed and runs until price takes it out. The line stops on the exact bar that crossed it. The wick counts, so it doesn't wait for a close. A level still holding is shown solid; once it gets taken it turns dashed and fades, and a small check is dropped on the bar that swept it. A small table in the corner lists each level and whether it has been swept.

Cross detection accounts for gaps, and the trading day is read from each symbol's own calendar rather than a fixed clock, so levels stay accurate on crypto, futures and stocks, on continuous charts and gapped ones alike.

Colors, line styles and width, label options, the sweep marker and the table are all configurable.

[b]Open source, free to study or extend.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Flip On Dip

// Key Daily Levels · by Flip On Dip
//
// what it does:
//   - marks the previous day's high & low  (PDH / PDL)
//   - marks the high & low of a session you pick (NY / London / Tokyo / Sydney / custom)
//   - if a session level sits on the exact same price as PDH/PDL it just merges
//     them into a single line so the chart stays clean -> e.g. "PDH (NY High)"
//   - once price runs a level it fades + dashes the line and drops a little check
//
// rule of thumb: solid line = still live, dashed & faded = already swept.
// been running this on my own charts for a while, finally tidied it up + made
// everything below configurable.

//@version=6
indicator("Key Daily Levels by Flip On Dip", "Key Daily Levels", overlay = true,
          max_lines_count  = 500,
          max_labels_count = 500)


// -------------------------------------------------------------------- session
gSess = "Session"
sessChoice = input.string("New York", "Session",
     options = ["New York", "London", "Tokyo (Asia)", "Sydney", "Custom"],
     group   = gSess,
     tooltip = "Which session's high & low to track next to PDH/PDL.")
customTz  = input.string("UTC", "Custom timezone", group = gSess,
     tooltip = "Only used when Session = Custom. e.g. UTC, America/New_York, Europe/London")
customHrs = input.string("1300-2200", "Custom hours (HHmm-HHmm)", group = gSess,
     tooltip = "Only used when Session = Custom. Read in the timezone above.")


// ------------------------------------------------------------------ PDH / PDL
gPD = "PDH / PDL"
showPD   = input.bool(true, "Show PDH / PDL", group = gPD)
colPDH   = input.color(#9598a1, "PDH color", group = gPD, inline = "pdh")
txtPDH   = input.string("PDH",  "",          group = gPD, inline = "pdh")
colPDL   = input.color(#9598a1, "PDL color", group = gPD, inline = "pdl")
txtPDL   = input.string("PDL",  "",          group = gPD, inline = "pdl")


// ------------------------------------------------------------- session levels
gSL = "Session High / Low"
showSess = input.bool(true, "Show session high / low", group = gSL)
colSHi   = input.color(#4c9aff, "Session high color", group = gSL)
colSLo   = input.color(#4c9aff, "Session low color",  group = gSL)


// ---------------------------------------------------------------------- lines
gLine = "Lines"
lineW      = input.int(1, "Width", minval = 1, maxval = 5, group = gLine)
styleLive  = input.string("Solid",  "Active style",
                          options = ["Solid", "Dashed", "Dotted"], group = gLine)
styleSwept = input.string("Dashed", "Swept style",
                          options = ["Solid", "Dashed", "Dotted"], group = gLine)
sweptFade  = input.int(72, "Swept fade (transparency)",
                       minval = 0, maxval = 100, group = gLine,
                       tooltip = "How see-through a level goes once it's swept. 0 = solid, 100 = gone.")
extendR    = input.bool(false, "Extend lines to the right edge", group = gLine)


// --------------------------------------------------------------------- labels
gLbl = "Labels"
showLbl   = input.bool(true,  "Show labels", group = gLbl)
showPrice = input.bool(false, "Show price on label", group = gLbl)
lblSide   = input.string("Left", "Label side",
                         options = ["Left", "Right"], group = gLbl,
                         tooltip = "Left pins the label where the level formed, Right keeps it at the current bar.")
colTxt    = input.color(color.silver, "Text color", group = gLbl)
txtSize   = input.string("Small", "Text size",
                         options = ["Tiny", "Small", "Normal"], group = gLbl)


// --------------------------------------------------------------- sweep marker
gChk = "Sweep marker"
showCheck = input.bool(true, "Show check when swept", group = gChk)
colCheck  = input.color(color.white, "Check color", group = gChk)


// ------------------------------------------------------------------ dashboard
gDash = "Dashboard"
showDash  = input.bool(true, "Show dashboard", group = gDash)
dashPos   = input.string("Top Right", "Position",
                         options = ["Top Right", "Middle Right", "Bottom Right"], group = gDash)
dashSize  = input.string("Small", "Size",
                         options = ["Tiny", "Small", "Normal"], group = gDash)
colDashTx = input.color(color.silver, "Text color", group = gDash)
colDashOk = input.color(color.lime,   "Swept marker", group = gDash)
colDashLv = input.color(#ff5252,      "Live marker",  group = gDash)


// small look-up helpers so the code below reads cleaner
sizeOf(s)  => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small
styleOf(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
posOf(s)   => s == "Middle Right" ? position.middle_right : s == "Bottom Right" ? position.bottom_right : position.top_right


// session presets, in each city's own local time w/ a DST-aware zone so the
// windows don't drift an hour twice a year. custom just falls through.
sessHrs = switch sessChoice
    "New York"     => "0800-1700"
    "London"       => "0800-1700"
    "Tokyo (Asia)" => "0900-1800"
    "Sydney"       => "0800-1700"
    => customHrs

sessZone = switch sessChoice
    "New York"     => "America/New_York"
    "London"       => "Europe/London"
    "Tokyo (Asia)" => "Asia/Tokyo"
    "Sydney"       => "Australia/Sydney"
    => customTz

sessTag = switch sessChoice
    "New York"     => "NY"
    "London"       => "London"
    "Tokyo (Asia)" => "Asia"
    "Sydney"       => "Sydney"
    => "Session"


// ------------------------------------------------------------------ the level
// one horizontal level + its line/labels + whatever state it's in
type Level
    float  price    = na
    bool   isHigh   = true
    bool   swept    = false
    line   ln       = na
    label  chk      = na    // the little check we drop on a sweep
    label  tag      = na    // the name bubble
    color  col      = na    // base color, we fade this one on sweep
    string name     = ""


// four slots, that's all we ever keep on screen
var Level pdh    = na
var Level pdl    = na
var Level sHi    = na
var Level sLo    = na

// running day range -> turns into PDH/PDL next day (+ the bar each extreme formed on)
var float dHigh  = na
var float dLow   = na
var int   dHighX = na
var int   dLowX  = na

// running session extremes -> pushed to the levels next day (+ their bars)
var float sHigh  = na
var float sLow   = na
var int   sHighX = na
var int   sLowX  = na

// first bar that RUNS a session extreme after it forms (can be the very same day
// it formed, right after the session closes). lets us cut the line on that exact
// cross instead of waiting for the next day's price to reach back to it.
var int   sHiCrossX = na
var int   sLoCrossX = na

var table dash = na


// builds the label text (name, optionally with the price tacked on)
lblText(string nm, float p) =>
    showPrice ? nm + "  " + str.tostring(p, format.mintick) : nm

// spin up a brand new level
newLevel(float p, bool isH, int x, string nm, color c) =>
    ex = extendR ? extend.right : extend.none
    ln = line.new(x, p, bar_index, p, color = c, style = styleOf(styleLive), width = lineW, extend = ex)
    label tl = na
    if showLbl
        st = isH ? label.style_label_down : label.style_label_up
        tl := label.new(x, p, text = lblText(nm, p), style = st,
                        color = color.new(color.white, 100), textcolor = colTxt, size = sizeOf(txtSize))
    Level.new(price = p, isHigh = isH, swept = false, ln = ln, chk = na, tag = tl, col = c, name = nm)

// when a session level lands on the same price as PDH/PDL we don't draw a 2nd
// line, we just fold the name in -> "PDH (NY High)"
foldIn(Level lv, string extra) =>
    lv.name := lv.name + " (" + extra + ")"
    if not na(lv.tag)
        label.set_text(lv.tag, lblText(lv.name, lv.price))

// keep the right end (and the label, if it lives on the right) glued to now
follow(Level lv) =>
    if not na(lv) and not na(lv.ln) and not lv.swept
        line.set_x2(lv.ln, bar_index)
        if lblSide == "Right" and not na(lv.tag)
            label.set_x(lv.tag, bar_index)

// did price cross this level on the current bar? works in both worlds:
//   - continuous (crypto): the bar trades straight through it  -> low < p < high
//   - gapped (futures / stocks): price jumps the level between two bars, so the
//     previous bar sits on one side and this bar is fully on the other side
// wick is enough, no close required.
crossed(float p) =>
    thru    = high > p and low < p
    gapUp   = high[1] <= p and low  > p
    gapDown = low[1]  >= p and high < p
    thru or gapUp or gapDown

// freeze a level on the bar that ran it: fade + dash the line, drop the check.
// atBar lets us cut it on an earlier bar (a same-day cross we caught after the fact)
markSwept(Level lv, int atBar) =>
    lv.swept := true
    line.set_x2(lv.ln, atBar)
    line.set_extend(lv.ln, extend.none)
    line.set_style(lv.ln, styleOf(styleSwept))
    line.set_color(lv.ln, color.new(lv.col, sweptFade))
    if showCheck
        // the newlines just nudge the check off the candle so it doesn't sit on the bubble
        txt = lv.isHigh ? "✓\n\n\n" : "\n\n\n✓"
        lv.chk := label.new(atBar, na, text = txt, style = label.style_none,
                            textcolor = colCheck, size = sizeOf(txtSize),
                            yloc = lv.isHigh ? yloc.abovebar : yloc.belowbar)

// live check: the moment a bar runs the level, cut it right there
testSweep(Level lv) =>
    if not na(lv) and not lv.swept and crossed(lv.price)
        markSwept(lv, bar_index)

// nuke everything a level owns
wipe(Level lv) =>
    if not na(lv)
        if not na(lv.ln)
            line.delete(lv.ln)
        if not na(lv.chk)
            label.delete(lv.chk)
        if not na(lv.tag)
            label.delete(lv.tag)

// one row in the dashboard
dashRow(int r, string nm, bool sw) =>
    cell = color.new(color.black, 70)
    sz   = sizeOf(dashSize)
    table.cell(dash, 0, r, "  " + nm, text_color = colDashTx, text_size = sz,
               bgcolor = cell, text_halign = text.align_left)
    table.cell(dash, 1, r, sw ? "  ✓" : "  ✗",
               text_color = sw ? colDashOk : colDashLv, text_size = sz,
               bgcolor = cell, text_halign = text.align_center)


// ------------------------------------------------------------ day / session
// new trading day per the symbol's OWN calendar (respects weekends, daily breaks
// and holidays), so PDH/PDL line up on crypto, futures and stocks alike. for
// 24/7 crypto this is still the 00:00 UTC daily close, so nothing changes there.
newDay = not barstate.isfirst and time("D") != time("D")[1]
inSess = not na(time(timeframe.period, sessHrs, sessZone))


// ==================================================================== engine

// new day rolled over -> redraw everything from yesterday's numbers
if newDay
    wipe(pdh)
    wipe(pdl)
    wipe(sHi)
    wipe(sLo)

    // PDH / PDL are the anchors, always draw them first (when we have the data)
    pdh := not na(dHigh) and showPD ? newLevel(dHigh, true,  dHighX, txtPDH, colPDH) : na
    pdl := not na(dLow)  and showPD ? newLevel(dLow,  false, dLowX,  txtPDL, colPDL) : na

    // session high: same price as PDH? fold in. otherwise it's its own line.
    sHi := na
    if not na(sHigh) and showSess
        if not na(pdh) and sHigh == pdh.price
            foldIn(pdh, sessTag + " High")
        else
            sHi := newLevel(sHigh, true, sHighX, sessTag + " High", colSHi)
            // already run on the day it formed? stop it right on that cross
            if not na(sHiCrossX)
                markSwept(sHi, sHiCrossX)

    // same deal for the session low vs PDL
    sLo := na
    if not na(sLow) and showSess
        if not na(pdl) and sLow == pdl.price
            foldIn(pdl, sessTag + " Low")
        else
            sLo := newLevel(sLow, false, sLowX, sessTag + " Low", colSLo)
            if not na(sLoCrossX)
                markSwept(sLo, sLoCrossX)

    // clear the session buckets for the day ahead
    sHigh     := na
    sLow      := na
    sHighX    := na
    sLowX     := na
    sHiCrossX := na
    sLoCrossX := na

    // seed today's range with the opening bar
    dHigh  := high
    dLow   := low
    dHighX := bar_index
    dLowX  := bar_index

// track today's high/low (and remember which bar made each extreme)
if na(dHigh)
    dHigh  := high
    dLow   := low
    dHighX := bar_index
    dLowX  := bar_index
else if not newDay
    if high > dHigh
        dHigh  := high
        dHighX := bar_index
    if low < dLow
        dLow  := low
        dLowX := bar_index

// track the chosen session's high/low while we're inside it
if inSess
    if na(sHigh) or high > sHigh
        sHigh  := high
        sHighX := bar_index
    if na(sLow) or low < sLow
        sLow  := low
        sLowX := bar_index

// watch for a session extreme getting run on the same day it formed, but only
// once the session is over and the extreme is final (the not-inSess guard keeps
// a mid-session doji from tripping the gap check).
if not inSess and not na(sHigh) and na(sHiCrossX) and crossed(sHigh)
    sHiCrossX := bar_index
if not inSess and not na(sLow) and na(sLoCrossX) and crossed(sLow)
    sLoCrossX := bar_index

// sweeps + keep the live lines extended
testSweep(pdh)
follow(pdh)
testSweep(pdl)
follow(pdl)
testSweep(sHi)
follow(sHi)
testSweep(sLo)
follow(sLo)


// -------------------------------------------------------------- dashboard
if barstate.islast and showDash
    // only count the slots that actually hold something
    rows = 1
    rows += not na(pdh) ? 1 : 0
    rows += not na(pdl) ? 1 : 0
    rows += not na(sHi) ? 1 : 0
    rows += not na(sLo) ? 1 : 0

    if not na(dash)
        table.delete(dash)

    dash := table.new(posOf(dashPos), 2, math.max(rows, 2),
                      bgcolor      = color.new(color.black, 80),
                      border_color = color.new(color.gray, 60),
                      border_width = 1,
                      frame_color  = color.new(color.gray, 40),
                      frame_width  = 1)

    hz = sizeOf(dashSize)
    table.cell(dash, 0, 0, "  Target", text_color = colDashTx, text_size = hz,
               bgcolor = color.new(color.gray, 50), text_halign = text.align_left)
    table.cell(dash, 1, 0, "Status", text_color = colDashTx, text_size = hz,
               bgcolor = color.new(color.gray, 50), text_halign = text.align_center)

    r = 1
    if not na(pdh)
        dashRow(r, pdh.name, pdh.swept)
        r += 1
    if not na(pdl)
        dashRow(r, pdl.name, pdl.swept)
        r += 1
    if not na(sHi)
        dashRow(r, sHi.name, sHi.swept)
        r += 1
    if not na(sLo)
        dashRow(r, sLo.name, sLo.swept)
        r += 1
````

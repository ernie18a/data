<!-- tradingview-pine-id: PUB;9187a0dea9a34338af4a781286ec47ed -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Previous Day High / Low

Source: https://www.tradingview.com/script/kTNrgBPr-Previous-Day-High-Low-PDH-PDL-Dated/

## Description

Here's a description you can paste into TradingView's publish form. I've kept it to what moderators look for: what it does, how it works, and how to use it, with no performance claims.

---

**Title:** Previous Day High / Low (PDH / PDL) — Dated

**Short title:** PDH / PDL

---

**Description:**

Marks the high and low of the previous trading day as two horizontal lines across the current session, with the source date printed on each line.

The previous day's range is one of the most widely watched reference levels in intraday trading. Price tends to react at yesterday's extremes — they act as obvious targets for continuation and as natural points for rejection. Most charts either leave you to eyeball those levels or clutter the screen with a week of stale lines. This one draws a single pair and tells you exactly which date they came from.

**How it works**

Yesterday's high and low are pulled from the daily timeframe using a security call with a one-bar offset and lookahead enabled. That combination returns only the last *closed* daily bar, so the values lock in the moment a new day opens and never shift afterwards. The levels do not repaint.

New days are detected from the daily timestamp rather than from bar counts, and the lines are anchored to time coordinates instead of bar indices. Both choices mean the script behaves the same on a 1-minute chart as on a 1-hour or daily chart, including on symbols with irregular sessions or gaps in data.

When a new session begins, the previous day's drawings are deleted and one fresh pair is created. Only ever one high line, one low line, and their labels exist on the chart.

**How to use it**

Add it to any intraday chart. The lines run from the session open to the live bar. Watch for:

- Breaks above PDH or below PDL as range expansion
- Failure and rejection at either level as a reversal signal
- The gap between the two as the prior day's value area, useful for gauging whether today is trending or rotating

Two alert conditions are included: *Cross above PDH* and *Cross below PDL*.

**Settings**

- **Regular trading hours only** — builds the daily range from the regular session, ignoring pre- and post-market. Useful for stocks; leave off for futures and crypto.
- **Line style** — colour, width (1–5), and dotted / dashed / solid. Defaults to yellow, width 2, dotted.
- **Extend right** — push the lines past the live bar by a set number of bars.
- **Label** — toggle on or off, choose the date format (MMM dd, dd/MM, yyyy-MM-dd, and others), optionally prefix with PDH/PDL or append the price, position left or right, set size and colour, and switch between plain text and a bubble.

**Note**

On weekly and monthly charts a "previous day" doesn't correspond to a bar, so the levels there are informational only. The indicator is intended for intraday and daily use.

---

Two things worth deciding before you hit publish: whether to release it as **open-source** (recommended — TradingView's house rules favour it, and a script this simple gains nothing from being protected), and whether to add a chart screenshot on a liquid symbol like ES or SPY with the lines clearly visible. The published snapshot is the first thing people judge, so set the chart up cleanly before you publish.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  Previous Day High / Low
//  • Works on every chart timeframe (1s → 1D and above)
//  • Shows ONE pair of levels only: the high/low of the day before today
//  • Yellow medium-thick dotted lines by default
//  • The line is labelled with the date it came from
// ═══════════════════════════════════════════════════════════════════════════
indicator("Previous Day High / Low", "PDH / PDL", overlay = true,
     max_lines_count = 10, max_labels_count = 10)

// ───────────────────────────── Inputs ─────────────────────────────────────
gGen       = "General"
useRTH     = input.bool(false, "Regular trading hours only", group = gGen,
     tooltip = "Build the daily high/low from the regular session only, ignoring pre/post market.")

gSty       = "Line style"
lineCol    = input.color(color.yellow, "Color", group = gSty, inline = "ln")
lineWid    = input.int(2, "Width", minval = 1, maxval = 5, group = gSty, inline = "ln")
styleIn    = input.string("Dotted", "Style", options = ["Dotted", "Dashed", "Solid"], group = gSty)
extendBars = input.int(0, "Extend right (bars)", minval = 0, maxval = 200, group = gSty)

gLbl       = "Label"
showLbl    = input.bool(true, "Show label", group = gLbl)
dateFmt    = input.string("MMM dd", "Date format",
     options = ["MMM dd", "dd MMM", "MM/dd", "dd/MM", "yyyy-MM-dd", "EEE MMM dd"], group = gLbl)
showTag    = input.bool(true, "Prefix with PDH / PDL", group = gLbl)
showPx     = input.bool(false, "Include price in label", group = gLbl)
lblSide    = input.string("Left", "Position", options = ["Left", "Right"], group = gLbl, inline = "lb")
lblSzIn    = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLbl, inline = "lb")
txtCol     = input.color(color.yellow, "Text color", group = gLbl)
bubble     = input.bool(false, "Draw label as bubble", group = gLbl)

// ─────────────────────────── Style mapping ────────────────────────────────
lStyle = switch styleIn
    "Dashed" => line.style_dashed
    "Solid"  => line.style_solid
    => line.style_dotted

lSize = switch lblSzIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

lblStyle = bubble
     ? (lblSide == "Left" ? label.style_label_right : label.style_label_left)
     : label.style_none

lblBg = bubble ? color.new(lineCol, 75) : color.new(color.black, 100)

// ──────────────────────────── Daily data ──────────────────────────────────
// ticker.modify lets us optionally exclude extended hours.
tkr = useRTH ? ticker.modify(syminfo.tickerid, session = session.regular) : syminfo.tickerid

// [1] offset + lookahead_on is the standard NON-repainting way to pull a
// completed higher-timeframe bar. Returns the last *closed* daily bar, so the
// values are fixed the moment the new day opens and never change afterwards.
[pdH, pdL, pdT] = request.security(tkr, "D", [high[1], low[1], time[1]],
     lookahead = barmerge.lookahead_on)

// New-day detection — works on intraday and on daily+ charts alike.
dTime  = time("D")
newDay = na(dTime[1]) or dTime != dTime[1]

// Milliseconds in one chart bar, used to place line/label x-coordinates.
barMs = timeframe.in_seconds(timeframe.period) * 1000

// ───────────────────────────── Helpers ────────────────────────────────────
mkTxt(tag, px, t) =>
    s = showTag ? tag + " " : ""
    s := s + str.format_time(t, dateFmt, syminfo.timezone)
    s := showPx ? s + "  " + str.tostring(px, format.mintick) : s
    s

// ───────────────────────────── Drawing ────────────────────────────────────
var line  hiLine = na
var line  loLine = na
var label hiLbl  = na
var label loLbl  = na

if newDay and not na(pdH) and not na(pdL)
    // Wipe the prior day's drawings so only the current date's PDH/PDL survive.
    line.delete(hiLine)
    line.delete(loLine)
    label.delete(hiLbl)
    label.delete(loLbl)

    startX = time
    endX   = time + barMs * (extendBars + 1)

    hiLine := line.new(startX, pdH, endX, pdH, xloc = xloc.bar_time,
         color = lineCol, style = lStyle, width = lineWid)
    loLine := line.new(startX, pdL, endX, pdL, xloc = xloc.bar_time,
         color = lineCol, style = lStyle, width = lineWid)

    if showLbl
        lblX = lblSide == "Left" ? startX : endX
        hiLbl := label.new(lblX, pdH, mkTxt("PDH", pdH, pdT), xloc = xloc.bar_time,
             style = lblStyle, color = lblBg, textcolor = txtCol, size = lSize)
        loLbl := label.new(lblX, pdL, mkTxt("PDL", pdL, pdT), xloc = xloc.bar_time,
             style = lblStyle, color = lblBg, textcolor = txtCol, size = lSize)

// Stretch the current day's lines to the live bar on every update.
if not na(hiLine)
    rightX = time + barMs * (extendBars + 1)
    line.set_x2(hiLine, rightX)
    line.set_x2(loLine, rightX)
    if showLbl and not na(hiLbl) and lblSide == "Right"
        label.set_x(hiLbl, rightX)
        label.set_x(loLbl, rightX)

// ───────────────────────────── Alerts ─────────────────────────────────────
alertcondition(ta.crossover(close, pdH),  "Cross above PDH", "Price crossed above previous day high")
alertcondition(ta.crossunder(close, pdL), "Cross below PDL", "Price crossed below previous day low")
````

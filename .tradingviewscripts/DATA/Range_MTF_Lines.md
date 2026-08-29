<!-- tradingview-pine-id: PUB;b3c4c1a0218c4ea9b51cacd9ba6b3381 -->
<!-- tradingviewscripts-format: 1 -->
# Range MTF Lines

Source: https://www.tradingview.com/script/TFoWlBzf-Range-MTF-Lines/

## Description

Range MTF Lines shows the direction of the current price range across four timeframes at once, as a compact strip in its own pane at the bottom of the chart.

How the range is defined

The first candle sets the initial range — its high and its low. The range stays alive for as long as candles keep closing inside it. The first candle that closes outside the range ends it, and that same candle's high and low immediately become the new range. Then it repeats.

Because every range is created by a close outside the previous one, each range is born with a direction:

Up (green) — it was created by a close above the old range
Down (red) — it was created by a close below the old range
Neutral (grey) — the very first range on the chart, which has no parent to break
What you see

Four rows, one per timeframe slot, at fixed heights: slot 1 on top, slot 4 at the bottom (defaults 5 / 15 / 30 / 60 minutes). Each row is coloured bar by bar with that timeframe's current range direction and is labelled with its timeframe at the right-hand end.

Because the rows live in their own pane at a fixed height, they never drift with price — you can zoom or scroll anywhere and the strip stays put and readable. Drag the pane divider to set how tall it is.

Reading it top to bottom tells you at a glance whether the short and long timeframes agree: all four green is broad one-way pressure, alternating colours means the lower timeframes are chopping inside a higher-timeframe range.

Settings

Row thickness — how chunky the rows are drawn
Tag rows with their timeframe — the label at the right end of each row
Per slot — show/hide, the timeframe, and separate colours for up, down and first range
Alert on break — per slot, fires on bar close when that timeframe forms a new range, and reports the new high and low
Each slot runs on its own timeframe independently of the chart's. A slot set to the chart timeframe is evaluated natively with no lag; higher timeframes are pulled in and track the live higher-timeframe bar.

Notes

This is a structure-reading tool, not a signal generator — it describes where price is relative to the ranges it keeps building, and nothing about the strip is predictive on its own. Ranges are decided on closes, so a wick outside the range does not end it. Companion script: Range Break Levels (MTF), which draws these same ranges on the candles themselves.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  RANGE MTF LINES
//
//  The direction strip only — the companion to "Range Break Levels (MTF)",
//  which draws the ranges themselves on the candles.
//
//  Range logic (identical to the boxes script, so the two always agree)
//  -------------------------------------------------------------------
//  1. The first available candle defines the initial range (its high / low).
//  2. The range stays alive while candles CLOSE inside it.
//  3. The first candle that CLOSES outside the range terminates it, and that
//     same candle's high / low becomes the NEW range.
//  4. Repeat forever.
//
//  Every range is therefore born from a break and carries a direction: UP when
//  it was created by a close ABOVE the old range, DOWN when created by a close
//  BELOW it. The very first range on the chart has no parent, so it is neutral.
//
//  Display
//  -------
//  This script lives in its OWN PANE (overlay = false) so the strip is pinned
//  to the bottom of the chart and never moves with price — drag the pane
//  divider to set its height. Up to 4 rows at fixed heights, one per slot:
//  slot 1 is the top row, slot 4 the bottom (defaults 5 / 15 / 30 / 60 min).
//  Each row is coloured bar by bar with that slot's range direction and tagged
//  with its timeframe at the right-hand end of the row.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Range MTF Lines", shorttitle = "Range MTF Lines", overlay = false)

// ───────────────────────────── Display ─────────────────────────────
grpS      = "Display"
stripWid  = input.int(6, "Row thickness", minval = 1, maxval = 20, group = grpS)
tagOn     = input.bool(true, "Tag rows with their timeframe", group = grpS,
     tooltip = "One label at the right-hand end of each row naming its timeframe.")

// ───────────────────────────── Slot inputs ─────────────────────────
grp1  = "Line 1"
en1   = input.bool(true, "Show line", group = grp1, inline = "s")
tf1   = input.timeframe("5", "TF", group = grp1, inline = "s")
cu1   = input.color(color.new(color.green, 0), "Up", group = grp1, inline = "c")
cd1   = input.color(color.new(color.red, 0),   "Down", group = grp1, inline = "c")
cn1   = input.color(color.new(color.gray, 0),  "First", group = grp1, inline = "c")
alr1  = input.bool(false, "Alert on break", group = grp1)

grp2  = "Line 2"
en2   = input.bool(true, "Show line", group = grp2, inline = "s")
tf2   = input.timeframe("15", "TF", group = grp2, inline = "s")
cu2   = input.color(color.new(color.green, 0), "Up", group = grp2, inline = "c")
cd2   = input.color(color.new(color.red, 0),   "Down", group = grp2, inline = "c")
cn2   = input.color(color.new(color.gray, 0),  "First", group = grp2, inline = "c")
alr2  = input.bool(false, "Alert on break", group = grp2)

grp3  = "Line 3"
en3   = input.bool(true, "Show line", group = grp3, inline = "s")
tf3   = input.timeframe("30", "TF", group = grp3, inline = "s")
cu3   = input.color(color.new(color.green, 0), "Up", group = grp3, inline = "c")
cd3   = input.color(color.new(color.red, 0),   "Down", group = grp3, inline = "c")
cn3   = input.color(color.new(color.gray, 0),  "First", group = grp3, inline = "c")
alr3  = input.bool(false, "Alert on break", group = grp3)

grp4  = "Line 4"
en4   = input.bool(true, "Show line", group = grp4, inline = "s")
tf4   = input.timeframe("60", "TF", group = grp4, inline = "s")
cu4   = input.color(color.new(color.green, 0), "Up", group = grp4, inline = "c")
cd4   = input.color(color.new(color.red, 0),   "Down", group = grp4, inline = "c")
cn4   = input.color(color.new(color.gray, 0),  "First", group = grp4, inline = "c")
alr4  = input.bool(false, "Alert on break", group = grp4)

// ───────────────────────── Core state machine ──────────────────────
// Runs on whatever timeframe it is evaluated in (chart or HTF via security).
// cnt increments every time a brand new range is established -> a change in cnt
// is the "range broke" trigger. dir carries how that range was born:
// 1 = broke up, -1 = broke down, 0 = the very first range (no parent).
rangeState() =>
    var float rH  = na
    var float rL  = na
    var int   cnt = 0
    var int   dir = 0
    if na(rH)
        rH  := high
        rL  := low
        dir := 0
        cnt += 1
    else if close > rH or close < rL
        dir := close > rH ? 1 : -1
        rH  := high
        rL  := low
        cnt += 1
    [rH, rL, cnt, dir]

// Slot TF == chart TF is evaluated natively (zero lag: the range flips on the
// very candle that breaks it). Higher TFs go through security and track the
// live HTF bar in real time.
getRange(simple string tf) =>
    simple bool isChart = tf == "" or tf == timeframe.period
    [nh, nl, nc, nd] = rangeState()
    [xh, xl, xc, xd] = request.security(syminfo.tickerid, tf, rangeState())
    float outH = isChart ? nh : xh
    float outL = isChart ? nl : xl
    int   outC = isChart ? nc : xc
    int   outD = isChart ? nd : xd
    [outH, outL, outC, outD]

// ─────────────────────────────── Wiring ────────────────────────────
[rh1, rl1, c1, d1] = getRange(tf1)
[rh2, rl2, c2, d2] = getRange(tf2)
[rh3, rl3, c3, d3] = getRange(tf3)
[rh4, rl4, c4, d4] = getRange(tf4)

name1 = tf1 == "" ? timeframe.period : tf1
name2 = tf2 == "" ? timeframe.period : tf2
name3 = tf3 == "" ? timeframe.period : tf3
name4 = tf4 == "" ? timeframe.period : tf4

// Direction colour of the live range, using that slot's own palette.
dirCol(int d, color cu, color cd, color cn) => d == 1 ? cu : d == -1 ? cd : cn

dc1 = dirCol(d1, cu1, cd1, cn1)
dc2 = dirCol(d2, cu2, cd2, cn2)
dc3 = dirCol(d3, cu3, cd3, cn3)
dc4 = dirCol(d4, cu4, cd4, cn4)

brk1 = not na(c1) and not na(c1[1]) and c1 != c1[1]
brk2 = not na(c2) and not na(c2[1]) and c2 != c2[1]
brk3 = not na(c3) and not na(c3[1]) and c3 != c3[1]
brk4 = not na(c4) and not na(c4[1]) and c4 != c4[1]

// ──────────────── Fixed rows in this script's pane ─────────────────
// Rows sit at constant heights (4 = slot 1 on top ... 1 = slot 4 at the
// bottom), so the strip is glued to the bottom of the chart and is completely
// independent of price. The two invisible plots hold the pane's scale steady
// so the rows keep their spacing whatever is switched on.
plot(0.4, "scale pad low",  color = na, display = display.pane, editable = false)
plot(4.6, "scale pad high", color = na, display = display.pane, editable = false)

float y1 = en1 ? 4.0 : na
float y2 = en2 ? 3.0 : na
float y3 = en3 ? 2.0 : na
float y4 = en4 ? 1.0 : na

plot(y1, "Line 1", color = dc1, linewidth = stripWid, style = plot.style_linebr)
plot(y2, "Line 2", color = dc2, linewidth = stripWid, style = plot.style_linebr)
plot(y3, "Line 3", color = dc3, linewidth = stripWid, style = plot.style_linebr)
plot(y4, "Line 4", color = dc4, linewidth = stripWid, style = plot.style_linebr)

// One timeframe tag per row, at the right-hand end only. The label is created
// ONCE and then moved along — creating a fresh one each time barstate.islast is
// true leaves a committed label behind on every bar that has been live, which
// litters the rows with duplicates as the session runs.
// Kept as three independent ifs rather than if/else: Pine types a block by its
// last statement, and an assignment branch (series label) next to a void call
// branch is a compile error.
tagRow(bool show, float y, string nm) =>
    var label lb = na
    if barstate.islast
        bool wantIt = show and tagOn and not na(y)
        if wantIt and na(lb)
            lb := label.new(bar_index + 3, y, nm, style = label.style_label_left,
                 color = color.new(chart.bg_color, 20), textcolor = chart.fg_color, size = size.small)
        if not wantIt and not na(lb)
            label.delete(lb)
            lb := na
        if not na(lb)
            label.set_xy(lb, bar_index + 3, y)
            label.set_text(lb, nm)

tagRow(en1, y1, name1)
tagRow(en2, y2, name2)
tagRow(en3, y3, name3)
tagRow(en4, y4, name4)

// ─────────────────────────────── Alerts ────────────────────────────
if brk1 and alr1 and barstate.isconfirmed
    alert("Range break " + name1 + " — new range " + str.tostring(rl1) + " / " + str.tostring(rh1), alert.freq_once_per_bar)
if brk2 and alr2 and barstate.isconfirmed
    alert("Range break " + name2 + " — new range " + str.tostring(rl2) + " / " + str.tostring(rh2), alert.freq_once_per_bar)
if brk3 and alr3 and barstate.isconfirmed
    alert("Range break " + name3 + " — new range " + str.tostring(rl3) + " / " + str.tostring(rh3), alert.freq_once_per_bar)
if brk4 and alr4 and barstate.isconfirmed
    alert("Range break " + name4 + " — new range " + str.tostring(rl4) + " / " + str.tostring(rh4), alert.freq_once_per_bar)
````

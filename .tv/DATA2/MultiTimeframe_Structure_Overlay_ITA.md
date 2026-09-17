<!-- tradingview-pine-id: PUB;bf74f6ae5c1348b19adf7ca9e71a7e86 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe Structure Overlay [ITA]

Source: https://www.tradingview.com/script/JeW9tUix-Multi-Timeframe-Structure-Overlay-ITA/

## Description

🟠 OVERVIEW

Multi-Timeframe Structure Overlay draws the structure of two higher timeframes
onto the chart you are actually trading.

Most multi-timeframe tools put the answer in a corner table: one hour bullish,
four hour bearish. That tells you the state but not where it sits, and price
does not trade against a table. Here the swing highs and lows those timeframes
are working with become lines on your chart, so you can see how far price is
from the level that would flip them.

Breaks are marked at the price where they happened, not in a corner.

🟠 CONCEPTS

* Higher Timeframe Structure - The swing highs and lows a larger timeframe has
confirmed. They are the levels that decide its direction, and they usually sit
somewhere your own timeframe never draws.
* Break of Structure - A close beyond the last confirmed swing in the direction
the timeframe was already going. Continuation.
* Change of Character - A break in the opposite direction to the previous one.
The first sign that the higher timeframe has turned, and marked separately
because it means something different.
* Bias - Which way each timeframe is currently pointing, based on its last
confirmed break. Shown as a small tag at the right edge rather than a panel.
* Alignment - Both higher timeframes pointing the same way. It has its own
alert, because that is usually the condition people are waiting for.

🟠 FEATURES

🔹 Two higher timeframes at once, each with its own colour, drawn as levels on
your chart rather than listed in a table

🔹 BOS and CHoCH labelled at the price where the break occurred, tagged with
which timeframe produced it

🔹 Bias tags at the right edge, offset from each other so they never overlap

🔹 A warning on the chart if a selected timeframe is lower than the one you are
viewing, instead of quietly drawing values that look plausible and mean nothing

🔹 Alignment alert for when both higher timeframes agree

🔹 Levels are requested with lookahead off and read from confirmed bars only,
so nothing shifts after the fact

🔹 Independent swing sensitivity, applied on each higher timeframe rather than
on your chart

🟠 HOW TO USE

Pick two timeframes above the one you are on. Working a 15 minute chart, one
hour and four hour is the usual pair. On a daily chart, use weekly and monthly.

Read the lines first. A higher timeframe level sitting just above price is the
level that flips its bias, and it is often nowhere near anything your own
timeframe would have drawn.

A CHoCH tag matters more than a BOS tag. Continuation is expected, a change of
character is the first evidence the larger move is turning.

When both bias tags point the same way, the higher timeframes agree. That is
the alignment alert, and it is usually a better filter than either timeframe on
its own.

Swing Lookback controls sensitivity on the higher timeframes. Raise it for
fewer and more significant levels.

🟠 CONCLUSION

Knowing the higher timeframe is bullish is not the same as knowing what price
has to do for that to change. This puts the second thing on the chart, where it
can actually be used.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Timeframe Structure Overlay [ITA]
//
// Every multi-timeframe structure tool I could find puts the answer in a
// corner table: 1H bullish, 4H bearish, Daily bullish. That tells you the
// state but not where it sits, and price does not trade against a table.
//
// This draws the higher timeframe structure on the chart you are actually
// looking at. The swing highs and lows that the higher timeframe is working
// with become lines on your chart, so you can see how far price is from the
// level that would flip it.
//
// Two higher timeframes can run at once. Break of structure and change of
// character are marked on each, at the price where they happened.
//
// Higher timeframe values are requested with lookahead off and read from
// confirmed bars only, so nothing shifts after the fact.
// =============================================================================

indicator("Multi-Timeframe Structure Overlay [ITA]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// ─── Inputs ──────────────────────────────────────────────────────────────────
grpTF = "Timeframes"
tf1 = input.timeframe("60", "Higher Timeframe 1", group = grpTF)
tf2 = input.timeframe("240", "Higher Timeframe 2", group = grpTF)
useTf2 = input.bool(true, "Enable The Second Timeframe", group = grpTF)
pivotLen = input.int(5, "Swing Lookback On Each", minval = 2, maxval = 30, group = grpTF,
     tooltip = "Bars either side of a swing point, measured on the higher timeframe.")

grpShow = "Display"
showLines = input.bool(true, "Draw The Structure Levels", group = grpShow)
showBreaks = input.bool(true, "Mark BOS and CHoCH", group = grpShow)
showBias = input.bool(true, "Bias Marker On The Last Bar", group = grpShow,
     tooltip = "A small tag at the right edge showing each timeframe's current state. Not a table.")
extendBars = input.int(20, "Extend Right (bars)", minval = 0, maxval = 200, group = grpShow)
lineWidth = input.int(2, "Line Width", minval = 1, maxval = 4, group = grpShow)

grpCol = "Colors"
col1 = input.color(#2962FF, "Timeframe 1", group = grpCol)
col2 = input.color(#9C27B0, "Timeframe 2", group = grpCol)
bullCol = input.color(#089981, "Bullish Break", group = grpCol)
bearCol = input.color(#F23645, "Bearish Break", group = grpCol)

// ─── Structure on one timeframe ──────────────────────────────────────────────
// Returns the current swing high and low, and whether the last confirmed break
// was upward (1), downward (-1) or none yet (0), plus whether that break was a
// change of character rather than a continuation.
structure() =>
    ph = ta.pivothigh(high, pivotLen, pivotLen)
    pl = ta.pivotlow(low, pivotLen, pivotLen)

    var float sh = na
    var float sl = na
    var int   dir = 0
    var bool  choch = false
    var int   sig = 0        // 1 bullish break, -1 bearish break, 0 nothing

    sig := 0

    if not na(ph)
        sh := ph
    if not na(pl)
        sl := pl

    if not na(sh) and close > sh
        choch := dir == -1
        dir := 1
        sig := 1
        sh := na
    else if not na(sl) and close < sl
        choch := dir == 1
        dir := -1
        sig := -1
        sl := na

    [sh, sl, dir, sig, choch]

[sh1, sl1, dir1, sig1, choch1] = request.security(syminfo.tickerid, tf1, structure(),
     lookahead = barmerge.lookahead_off)
[sh2, sl2, dir2, sig2, choch2] = request.security(syminfo.tickerid, useTf2 ? tf2 : tf1,
     structure(), lookahead = barmerge.lookahead_off)

// ─── Drawing ─────────────────────────────────────────────────────────────────
var line hi1 = na
var line lo1 = na
var line hi2 = na
var line lo2 = na
var label bias1 = na
var label bias2 = na

// A level is only worth drawing while it is still unbroken.
drawLevel(line ln, float price, color c, bool on) =>
    line out = ln
    if on and not na(price)
        if na(out)
            out := line.new(bar_index - 1, price, bar_index + extendBars, price,
                 color = c, width = lineWidth, style = line.style_solid)
        else
            line.set_xy1(out, bar_index - 1, price)
            line.set_xy2(out, bar_index + extendBars, price)
            line.set_color(out, c)
    else if not na(out)
        line.delete(out)
        out := na
    out

if barstate.islast
    hi1 := drawLevel(hi1, sh1, col1, showLines)
    lo1 := drawLevel(lo1, sl1, col1, showLines)
    hi2 := drawLevel(hi2, sh2, col2, showLines and useTf2)
    lo2 := drawLevel(lo2, sl2, col2, showLines and useTf2)

// ─── Break markers, drawn at the price where they happened ───────────────────
tag(int sig, bool choch, string tfName, color c) =>
    txt = (choch ? "CHoCH " : "BOS ") + tfName
    y = sig == 1 ? high : low
    st = sig == 1 ? label.style_label_down : label.style_label_up
    label.new(bar_index, y, txt, style = st, color = c,
         textcolor = color.white, size = size.tiny)

if showBreaks and sig1 != 0 and sig1 != sig1[1]
    tag(sig1, choch1, tf1, sig1 == 1 ? bullCol : bearCol)

if showBreaks and useTf2 and sig2 != 0 and sig2 != sig2[1]
    tag(sig2, choch2, tf2, sig2 == 1 ? bullCol : bearCol)

// ─── Bias tags at the right edge ─────────────────────────────────────────────
biasText(string tfName, int dir) =>
    state = dir == 1 ? "up" : dir == -1 ? "down" : "flat"
    tfName + "  " + state

// The two tags have to sit apart. Placed at the same price they overlap and
// only the second one is ever visible.
gap = ta.atr(14) * 1.2

if barstate.islast and showBias
    c1 = dir1 == 1 ? bullCol : dir1 == -1 ? bearCol : color.gray
    y1 = close + gap
    if na(bias1)
        bias1 := label.new(bar_index + extendBars, y1, biasText(tf1, dir1),
             style = label.style_label_left, color = c1,
             textcolor = color.white, size = size.small)
    else
        label.set_xy(bias1, bar_index + extendBars, y1)
        label.set_text(bias1, biasText(tf1, dir1))
        label.set_color(bias1, c1)

    if useTf2
        c2 = dir2 == 1 ? bullCol : dir2 == -1 ? bearCol : color.gray
        y2 = close - gap
        if na(bias2)
            bias2 := label.new(bar_index + extendBars, y2, biasText(tf2, dir2),
                 style = label.style_label_left, color = c2,
                 textcolor = color.white, size = size.small)
        else
            label.set_xy(bias2, bar_index + extendBars, y2)
            label.set_text(bias2, biasText(tf2, dir2))
            label.set_color(bias2, c2)

// ─── Guard: a "higher" timeframe that is actually lower ──────────────────────
// Requesting 60 minutes while sitting on a daily chart returns values that
// look plausible and mean nothing. Say so on the chart rather than drawing
// quietly wrong lines.
var label warnLbl = na

chartSecs = timeframe.in_seconds(timeframe.period)
tooLow1 = timeframe.in_seconds(tf1) < chartSecs
tooLow2 = useTf2 and timeframe.in_seconds(tf2) < chartSecs

if barstate.islast
    msg = ""
    if tooLow1 and tooLow2
        msg := "Both selected timeframes are lower than this chart. Pick timeframes above " + timeframe.period + "."
    else if tooLow1
        msg := "Timeframe 1 (" + tf1 + ") is lower than this chart. Pick one above " + timeframe.period + "."
    else if tooLow2
        msg := "Timeframe 2 (" + tf2 + ") is lower than this chart. Pick one above " + timeframe.period + "."

    if msg != ""
        if na(warnLbl)
            warnLbl := label.new(bar_index, high, msg, style = label.style_label_down,
                 color = color.new(#F23645, 15), textcolor = color.white, size = size.small)
        else
            label.set_xy(warnLbl, bar_index, high)
            label.set_text(warnLbl, msg)
    else if not na(warnLbl)
        label.delete(warnLbl)
        warnLbl := na

// ─── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(sig1 != 0 and sig1 != sig1[1], "HTF 1 Structure Break",
     "Higher timeframe 1 broke structure")
alertcondition(sig2 != 0 and sig2 != sig2[1], "HTF 2 Structure Break",
     "Higher timeframe 2 broke structure")
alertcondition(dir1 == dir2 and dir1 != 0 and (dir1 != dir1[1] or dir2 != dir2[1]),
     "Both Timeframes Aligned",
     "Both higher timeframes are now pointing the same way")
````

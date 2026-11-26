# High Time Frame Candle Overlay

- url: https://www.tradingview.com/script/OEEkXxfK-High-Time-Frame-Candle-Overlay/
- type: indicator
- pine_id: PUB;218021793af34a9aa7ed7e6999432bbd
- version: 2.0

## Description

Overlay higher-timeframe (HTF) candles on the same pane as the chart. Each HTF candle spans the lower-timeframe bars that belong to that period, using the same OHLC aggregation as a normal HTF candle: open of the first bar, high/low of the range, close of the last bar (updates while the HTF bar is still forming).

This is a [b]visual overlay only[/b]. It does not generate buy or sell signals and is not a trading system.

[b]Why use it[/b]

Read the higher-timeframe candle (body, wick, close relative to open) without leaving the working timeframe. Example: on a 15-minute chart, each 1-hour candle covers the four 15-minute bars that form that hour.

[b]Auto HTF (on by default)[/b]

The overlay timeframe follows the chart:

[list]
[*] 1m → 5m
[*] 5m → 15m
[*] 15m → 1h
[*] 1h → 4h
[*] 4h → 1D
[*] 1D → 1W
[*] 1W → 1M
[/list]

Turn [b]Auto HTF from chart[/b] off to pick 1m, 5m, 15m, 1h, 4h, 1D, 1W, or 1M manually. The overlay must be [b]higher[/b] than the chart timeframe.

[b]Alignment[/b]

Period edges follow TradingView session/clock for that timeframe (same boundaries as the built-in HTF chart), not “every N bars from bar 0”.

The right edge stops on the [b]last chart bar of the HTF period (its close)[/b], not on the next HTF open. Example: 4h chart + 1D overlay — the daily candle runs from the 08:00 open through the 04:00–08:00 bar close, not through the next day’s 08:00 open.

X uses bar index (stays glued when you pan or the chart auto-fits). Y is price.

[b]Candle styles[/b]

[list]
[*] [b]One candle[/b] — one body and a center wick (default).
[*] [b]Four sections[/b] — the same HTF OHLC split into four columns, with a wick band in each column so the wick is easier to see against the chart’s own wicks.
[/list]

[b]Colors and look[/b]

Same layout as TradingView candle style: Body, Border, and Wick, each with bull and bear colors (close ≥ open = bull). Color pickers include their own transparency. A separate [b]Transparency[/b] input (0–100) sets body fill so the chart candles stay visible underneath.

Also adjustable: wick width, body border width, and how many HTF candles to keep (platform max 500 drawings; Four sections uses more drawings per candle, so the script caps that style at 62).

[b]How to use[/b]

[list]
[*] Add the script to a standard candlestick chart (not Heikin Ashi, Renko, or other non-standard types if you need real OHLC).
[*] Leave Auto HTF on, or turn it off and choose Overlay timeframe.
[*] Raise Transparency if the overlay hides the chart candles; lower it if the HTF body is too faint.
[*] Switch to Four sections if the center wick is hard to read.
[/list]

[b]Notes[/b]

[list]
[*] The first HTF candle at the left of loaded history may be a partial period if the first bar is not an HTF boundary.
[*] Missing chart bars can make the overlay open differ slightly from the exchange HTF print.
[*] Doji (open = close) uses bull colors, same as TradingView candles.
[/list]

## Source Code

````pine
//@version=6
indicator("HTF Candle Overlay", overlay = true, behind_chart = false, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 5)

// =============================================================================
// Visual overlay only. Not a signal. Not a trading system.
//
// Draws higher-timeframe candles in THIS pane, each candle spanning the
// lower-TF bars that belong to that HTF period (e.g. four 15m bars → one 1h).
//
// Styles:
//   One candle    — one body + wick. Box x is exclusive-right (left=N,
//                   right=N+1 covers bar N). 4+ LTF bars (15m→1h, 1h→4h,
//                   4h→1D, 1D→1W): upper/lower wick rectangles two bars
//                   wide, same fill and border as the body — not a thin
//                   line (a 1px wick on a 6-bar 4h→1D body looks like a
//                   needle vs a native 1D wick). 3 LTF bars (5m→15m):
//                   center line.
//   Four sections — same HTF OHLC, 4 columns. Each column uses the same
//                   Body / Border / Wick colors, Transparency, and widths.
//
// OHLC is the same aggregation a regular HTF candle uses:
//   open  = first chart-bar open in the HTF period
//   high  = max high
//   low   = min low
//   close = last chart-bar close  (updates every tick while the HTF bar is live)
//
// X is xloc.bar_index (same axis as price candles). Y is price.
// Right edge: last LTF bar of the HTF period (its close), NOT the next HTF open.
// e.g. 4h chart + 1D: day is 08:00 open → 08:00 close (the 04:00–08:00 bar),
// not 08:00 open → next day 08:00 open.
//
// Auto HTF (default on): 1m→5m, 5m→15m, 15m→1h, 1h→4h, 4h→1D, 1D→1W, 1W→1M.
// Pine v6: indicator() has no calc_on_every_tick (strategy() only).
// =============================================================================

group_tf = "Timeframe"
autoHtf = input.bool(true, "Auto HTF from chart", group = group_tf,
     tooltip = "On: 1m→5m, 5m→15m, 15m→1h, 1h→4h, 4h→1D, 1D→1W, 1W→1M. Off: use Overlay timeframe.")
htfPick = input.string("1h", "Overlay timeframe", options = ["1m", "5m", "15m", "1h", "4h", "1d", "1w", "1M"], group = group_tf,
     active = not autoHtf,
     tooltip = "Used only when Auto HTF is off. Must be higher than the chart timeframe.")

group_vis = "Candle look"
stylePick = input.string("One candle", "Candle style", options = ["One candle", "Four sections"], group = group_vis,
     tooltip = "One candle: body + wick. 4+ LTF bars (15m→1h, 4h→1D): two-bar wick rectangles, same fill/border as the body. 3 bars (5m→15m): center line. Four sections: 4 columns.")
// input.int options signature (v6): dropdown. Cannot mix with minval/maxval.
transp = input.int(55, "Transparency",
     options = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100],
     group = group_vis,
     tooltip = "Body and wick fill. 0 = solid, 100 = invisible.")
wick_width = input.int(2, "Wick width", minval = 1, maxval = 4, group = group_vis,
     tooltip = "One candle, 3 LTF bars: line px. One candle, 4+ LTF bars: unused (wick is a two-bar rectangle). Four sections: wick-band thickness in each column (1 = thin, 4 = full column).")
border_width = input.int(1, "Body border width", minval = 0, maxval = 3, group = group_vis)
// One candle: 1 box + 1 line → 500. Four sections: 8 boxes (4 wicks + 4 bodies) → 62.
max_candles = input.int(500, "Max HTF candles to keep", minval = 1, maxval = 500, group = group_vis,
     tooltip = "One candle: capped at 166 (3 boxes each). Four sections: capped at 62 (8 boxes each). Platform max 500 boxes.")

group_col = "Colors (body and wick share the same fill; border is separate)"
bull_col = input.color(#26a69a, "Body  ", inline = "body", group = group_col, tooltip = "Bull body and wick (close ≥ open)")
bear_col = input.color(#ef5350, "", inline = "body", group = group_col, tooltip = "Bear body and wick (close < open)")
bull_frame = input.color(#26a69a, "Border", inline = "frame", group = group_col, tooltip = "Bull frame")
bear_frame = input.color(#ef5350, "", inline = "frame", group = group_col, tooltip = "Bear frame")

htfTf() =>
    switch htfPick
        "1m" => "1"
        "5m" => "5"
        "15m" => "15"
        "1h" => "60"
        "4h" => "240"
        "1d" => "1D"
        "1w" => "1W"
        "1M" => "1M"
        => "60"

// Next rung on the ladder. In-between chart TFs (3m, 2h, …) use the step above them.
autoTf() =>
    switch timeframe.period
        "1" => "5"
        "5" => "15"
        "15" => "60"
        "60" => "240"
        "240" => "1D"
        "D" => "1W"
        "1D" => "1W"
        "W" => "1M"
        "1W" => "1M"
        =>
            int s = timeframe.in_seconds()
            s <= 60 ? "5" : s <= 300 ? "15" : s <= 900 ? "60" : s <= 3600 ? "240" : s <= 14400 ? "1D" : s <= 86400 ? "1W" : "1M"

string tf = autoHtf ? autoTf() : htfTf()
int chartSec = timeframe.in_seconds()
int htfSec = timeframe.in_seconds(tf)
bool valid = not na(chartSec) and not na(htfSec) and htfSec > chartSec
bool fourSec = stylePick == "Four sections"
// One candle: 3 boxes + 1 line → 166. Four sections: 8 boxes → 62.
int keep = fourSec ? math.min(max_candles, 62) : math.min(max_candles, 166)

var float o = na
var float h = na
var float l = na
var float c = na
var int leftBar = na
var box bodyBx = na
var line wickLn = na
var box wickHi = na
var box wickLo = na
var box w0 = na
var box w1 = na
var box w2 = na
var box w3 = na
var box sec0 = na
var box sec1 = na
var box sec2 = na
var box sec3 = na
var label warn = na

var array<box> bodies = array.new<box>()
var array<line> wickLns = array.new<line>()
var array<box> wickHis = array.new<box>()
var array<box> wickLos = array.new<box>()
var array<box> wick0s = array.new<box>()
var array<box> wick1s = array.new<box>()
var array<box> wick2s = array.new<box>()
var array<box> wick3s = array.new<box>()
var array<box> secs0 = array.new<box>()
var array<box> secs1 = array.new<box>()
var array<box> secs2 = array.new<box>()
var array<box> secs3 = array.new<box>()

f_pick(float op, float cl, color bullC, color bearC) =>
    cl >= op ? bullC : bearC

// Expected LTF bars per HTF candle (15m→1h = 4, 5m→15m = 3).
f_htf_ratio() =>
    chartSec > 0 ? math.max(1, int(math.round(htfSec / chartSec))) : 1

f_new_box() =>
    box.new(bar_index, open, bar_index + 1, open, xloc = xloc.bar_index, force_overlay = true, border_width = border_width)

f_edge(int i, int left, int right) =>
    int span = math.max(right - left, 1)
    left + int(i * span / 4)

// Centered wick band inside [sl, sr). Thickness follows wick_width (1–4).
f_wick_left(int sl, int sr) =>
    int span = math.max(sr - sl, 1)
    int w = math.max(1, int(math.round(span * wick_width / 4.0)))
    int mid = int(math.floor(0.5 * (sl + sr)))
    math.max(sl, mid - int(math.floor(w / 2.0)))

f_wick_right(int sl, int sr) =>
    int span = math.max(sr - sl, 1)
    int w = math.max(1, int(math.round(span * wick_width / 4.0)))
    math.min(sr, f_wick_left(sl, sr) + w)

// Last LTF bar of this HTF period: the *next* chart bar belongs to a new HTF.
// Uses time(tf, bars_back = -1) (v6) so it still works when session close
// ≠ calendar HTF close (e.g. 1D→1W Fri vs Mon, or a 4h bar that ends at 08:00).
f_is_htf_last() =>
    int htfNow = time(tf)
    int htfNext = time(tf, bars_back = -1)
    int htfClose = time_close(tf)
    bool nextIsNew = not na(htfNow) and not na(htfNext) and htfNext != htfNow
    bool closeMatches = not na(time_close) and not na(htfClose) and time_close == htfClose
    nextIsNew or closeMatches

f_hide_line(line ln) =>
    if na(ln)
        false
    else
        line.set_color(ln, color.new(color.white, 100))
        true

f_paint_box(box bx, int left, int right, float top, float bot, color bg, color frame, int bw) =>
    if na(bx)
        false
    else if right <= left
        box.set_bgcolor(bx, color.new(color.white, 100))
        box.set_border_color(bx, color.new(color.white, 100))
        true
    else
        float topY = math.max(top, bot)
        float botY = math.min(top, bot)
        box.set_xloc(bx, left, right, xloc.bar_index)
        box.set_lefttop(bx, left, topY)
        box.set_rightbottom(bx, right, botY)
        box.set_bgcolor(bx, bg)
        box.set_border_color(bx, frame)
        box.set_border_width(bx, bw)
        true

f_trim() =>
    while array.size(bodies) > keep
        box.delete(array.shift(bodies))
        if array.size(wickLns) > 0
            line.delete(array.shift(wickLns))
        if array.size(wickHis) > 0
            box.delete(array.shift(wickHis))
        if array.size(wickLos) > 0
            box.delete(array.shift(wickLos))
    while array.size(secs0) > keep
        box.delete(array.shift(secs0))
        if array.size(secs1) > 0
            box.delete(array.shift(secs1))
        if array.size(secs2) > 0
            box.delete(array.shift(secs2))
        if array.size(secs3) > 0
            box.delete(array.shift(secs3))
        if array.size(wick0s) > 0
            box.delete(array.shift(wick0s))
        if array.size(wick1s) > 0
            box.delete(array.shift(wick1s))
        if array.size(wick2s) > 0
            box.delete(array.shift(wick2s))
        if array.size(wick3s) > 0
            box.delete(array.shift(wick3s))
    true

// lastBar = last LTF bar in this HTF period (inclusive bar index).
// visRight = lastBar+1 (exclusive): right edge is that bar's close.
f_draw(int lastBar, bool closeAtThisBar) =>
    if na(leftBar) or na(o) or na(h) or na(l) or na(c)
        false
    else
        // Exclusive-right: left=N, right=N+1 covers bar N (see f_new_box).
        // lastBar+1 is the last LTF bar's close — same x as the next HTF open,
        // but the box does not fill the next bar.
        int rightEx = lastBar + 1
        int visRight = rightEx
        color bodyC = f_pick(o, c, bull_col, bear_col)
        color frameC = f_pick(o, c, bull_frame, bear_frame)
        color bodyFill = color.new(bodyC, transp)
        color wickFill = bodyFill
        color wickFrame = color.new(bodyC, 100)
        float rawTop = math.max(o, c)
        float rawBot = math.min(o, c)
        float rng = math.max(h - l, syminfo.mintick)
        float pad = rawTop == rawBot ? math.max(syminfo.mintick, rng * 0.02) : 0.0
        if fourSec
            int a0 = f_edge(0, leftBar, rightEx)
            int a1 = f_edge(1, leftBar, rightEx)
            int a2 = f_edge(2, leftBar, rightEx)
            int a3 = f_edge(3, leftBar, rightEx)
            int a4 = f_edge(4, leftBar, rightEx)
            f_paint_box(w0, f_wick_left(a0, a1), math.min(f_wick_right(a0, a1), visRight), h, l, wickFill, wickFrame, 0)
            f_paint_box(w1, f_wick_left(a1, a2), math.min(f_wick_right(a1, a2), visRight), h, l, wickFill, wickFrame, 0)
            f_paint_box(w2, f_wick_left(a2, a3), math.min(f_wick_right(a2, a3), visRight), h, l, wickFill, wickFrame, 0)
            f_paint_box(w3, f_wick_left(a3, a4), math.min(f_wick_right(a3, a4), visRight), h, l, wickFill, wickFrame, 0)
            f_paint_box(sec0, a0, math.min(a1, visRight), rawTop + pad, rawBot - pad, bodyFill, frameC, border_width)
            f_paint_box(sec1, a1, math.min(a2, visRight), rawTop + pad, rawBot - pad, bodyFill, frameC, border_width)
            f_paint_box(sec2, a2, math.min(a3, visRight), rawTop + pad, rawBot - pad, bodyFill, frameC, border_width)
            f_paint_box(sec3, a3, math.min(a4, visRight), rawTop + pad, rawBot - pad, bodyFill, frameC, border_width)
            true
        else if na(bodyBx) or na(wickLn) or na(wickHi) or na(wickLo)
            false
        else
            // Live: keep expected HTF width so the wick does not jump as bars
            // arrive. Closed: actual LTF count (session 1D on 4h can be 5–7).
            int nBars = math.max(1, lastBar - leftBar + 1)
            int expected = f_htf_ratio()
            int nUse = closeAtThisBar or f_is_htf_last() ? nBars : math.max(nBars, expected)
            int midBar = leftBar + int(nUse / 2)
            // Exclusive-right two-bar band at the visual center.
            // 4 bars L..L+3 → 2nd & 3rd = [L+1, L+3).  6 bars L..L+5 → 3rd & 4th = [L+2, L+4).
            int bandLeft = leftBar + int(nUse / 2) - 1
            int bandRightEx = bandLeft + 2
            // 4+ LTF bars: two-bar wick rectangles (4h→1D must not be a thin line).
            // 3 LTF bars (5m→15m): center line only.
            bool wickBoxes = nUse >= 4
            if wickBoxes
                int wl = math.max(leftBar, bandLeft)
                int wr = math.min(visRight, bandRightEx)
                bool hasUp = h > rawTop
                bool hasDn = l < rawBot
                f_paint_box(wickHi, hasUp ? wl : 0, hasUp ? wr : 0, h, rawTop, bodyFill, frameC, border_width)
                f_paint_box(wickLo, hasDn ? wl : 0, hasDn ? wr : 0, rawBot, l, bodyFill, frameC, border_width)
                f_hide_line(wickLn)
            else
                f_paint_box(wickHi, 0, 0, h, rawTop, wickFill, wickFill, 0)
                f_paint_box(wickLo, 0, 0, rawBot, l, wickFill, wickFill, 0)
                int mid = math.min(lastBar, math.max(leftBar, midBar))
                line.set_xloc(wickLn, mid, mid, xloc.bar_index)
                line.set_xy1(wickLn, mid, h)
                line.set_xy2(wickLn, mid, l)
                line.set_color(wickLn, wickFill)
                line.set_width(wickLn, wick_width)
            f_paint_box(bodyBx, leftBar, visRight, rawTop + pad, rawBot - pad, bodyFill, frameC, border_width)
            true

if valid and not na(time(tf))
    bool newHtf = barstate.isfirst or timeframe.change(tf)
    if newHtf
        // Lock the completed HTF candle to its last LTF bar (close), not this bar's open.
        if not na(o)
            f_draw(bar_index - 1, true)
        o := open
        h := high
        l := low
        c := close
        leftBar := bar_index
        if fourSec
            w0 := f_new_box()
            w1 := f_new_box()
            w2 := f_new_box()
            w3 := f_new_box()
            sec0 := f_new_box()
            sec1 := f_new_box()
            sec2 := f_new_box()
            sec3 := f_new_box()
            array.push(wick0s, w0)
            array.push(wick1s, w1)
            array.push(wick2s, w2)
            array.push(wick3s, w3)
            array.push(secs0, sec0)
            array.push(secs1, sec1)
            array.push(secs2, sec2)
            array.push(secs3, sec3)
        else
            bodyBx := f_new_box()
            wickLn := line.new(bar_index, high, bar_index, low, xloc = xloc.bar_index, force_overlay = true, width = wick_width)
            wickHi := f_new_box()
            wickLo := f_new_box()
            array.push(bodies, bodyBx)
            array.push(wickLns, wickLn)
            array.push(wickHis, wickHi)
            array.push(wickLos, wickLo)
        f_trim()
    else if not na(o)
        h := math.max(h, high)
        l := math.min(l, low)
        c := close
    f_draw(bar_index, false)

if barstate.islast
    if not na(warn)
        label.delete(warn)
        warn := na
    if not valid
        warn := label.new(bar_index, high,
             "Overlay TF must be higher than the chart TF\nchart " + timeframe.period + "  vs  " + tf + (autoHtf ? " (auto)" : ""),
             style = label.style_label_left,
             color = color.new(color.orange, 10),
             textcolor = color.black,
             size = size.small)

plot(valid ? o : na, "HTF Open", display = display.data_window)
plot(valid ? h : na, "HTF High", display = display.data_window)
plot(valid ? l : na, "HTF Low", display = display.data_window)
plot(valid ? c : na, "HTF Close", display = display.data_window)
````

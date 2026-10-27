# Previous Day / Week / Month Range Levels

- url: https://www.tradingview.com/script/sZDcyNfx-Previous-Day-Week-Month-Range-Levels/
- type: indicator
- pine_id: PUB;5f659cb5593641ffb7ffac55e59d89cd
- version: 2.0

## Description

Draws the high, low and internal subdivisions of the last completed period on up to three higher timeframes at once.

Why the prior range matters

A finished period leaves behind a structure the market keeps referring back to. Yesterday's high and low are where yesterday's argument was settled, and price spends a surprising amount of the next session negotiating with those two numbers — breaking them, failing at them, or holding between them.

The subdivisions add resolution to that. The midpoint separates the upper and lower half of the range, and which side price accepts on tells you who won the period. The quarters mark the shallow zones inside each half — the levels a pullback reaches before it has retraced anything meaningful.

What it draws

Prior period high and low, as solid boundary lines
Midpoint at 50%
Quarters at 25% and 75%
Optional eighths at 12.5% and 87.5% for wider ranges
Price labels on every level, with the timeframe named

Three timeframe slots, each with its own colour and on/off switch. Defaults are Daily and Weekly enabled, Monthly available. Any timeframe works — 4H, quarterly, yearly — so intraday traders and swing traders can both configure it sensibly.

The levels do not repaint

Each level is read from the previous completed bar of its timeframe using a lookahead-safe request. Once a period closes, its levels are fixed and will not move. Nothing is recalculated on the developing bar, and nothing you see on historical bars was drawn with information from the future.

That means the numbers are frozen for the whole current period. The daily levels you see at the open are the same ones at the close.

Notes on use

Session settings matter. On a chart set to regular hours, the daily range is built from regular-hours prices only — switch to extended hours and every level moves. Neither is wrong, but be deliberate about which one you're reading.

Multi-period timeframes such as 2W or 6M are grouped by TradingView from a fixed reference point, which may not align with where you'd assume a fortnight begins. Worth eyeballing directly before relying on them.

Drawings are anchored by timestamp rather than bar index, so they stay put when you scroll back and TradingView loads more history. Bar indices renumber every time more history loads; timestamps do not.

There is also a fully transparent plot of close in there, doing a job that is easy to miss. Lines and labels do not feed TradingView's autoscale, so a script that only draws has no price range of its own and can be handed a separate price scale — at which point every level sits at an offset from the candles. The transparent plot gives the script a real range and locks it to the symbol's.

Settings

Three timeframe slots, each with an enable toggle, a timeframe and a colour
Midpoint, quarters and eighths switched independently
Price labels on or off, with a size option
Boundary line width, and a separate transparency for the inner levels so the range edges stay dominant
Extend left and extend right, in bars

Open source. Read it, fork it, adapt it. The non-repainting request pattern, the time-anchored drawing and the scale anchor are all worth stealing for your own scripts.

For educational purposes only. Nothing here is financial advice, a recommendation, or a solicitation to trade. Levels are reference points, not signals.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  PREVIOUS DAY / WEEK / MONTH RANGE LEVELS
//  by Thinkless Trade
//
//  Draws the high, low and internal subdivisions of the last COMPLETED period
//  on up to three higher timeframes at once.
//
//  Why the subdivisions matter: a completed range is a reference structure the
//  market keeps returning to. Its midpoint separates the upper and lower half —
//  price accepting above or below it says something. The quarters mark the
//  shallow retracement zones inside each half.
//
//  Labels come two ways. Short prints the timeframe code — D High, W Low — and
//  stays out of the way when several timeframes are on at once. Descriptive
//  spells it out — Previous Day High, Previous Week Low — which is the better
//  setting for one timeframe, for screenshots, and while the levels are still
//  new to you.
//
//  The levels are non-repainting. Each one is read from the PREVIOUS completed
//  bar of its timeframe using a lookahead-safe request, so a level never moves
//  once its period has closed. Everything is fixed for the duration of the
//  current period and only updates at the boundary.
//
//  Free and open source. Use it, fork it, learn from it.
// ═══════════════════════════════════════════════════════════════════════════

indicator("Previous Day / Week / Month Range Levels", "HTF Range Levels",
     overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────────────────────────────────────────────────────────
//  INPUTS
// ───────────────────────────────────────────────────────────────────────────
g1 = "Timeframe 1"
on1 = input.bool(true,  "Enabled", group = g1, inline = "a")
tf1 = input.timeframe("D", "", group = g1, inline = "a")
c1  = input.color(#4FC3F7, "", group = g1, inline = "a")

g2 = "Timeframe 2"
on2 = input.bool(true,  "Enabled", group = g2, inline = "a")
tf2 = input.timeframe("W", "", group = g2, inline = "a")
c2  = input.color(#3570D0, "", group = g2, inline = "a")

g3 = "Timeframe 3"
on3 = input.bool(false, "Enabled", group = g3, inline = "a")
tf3 = input.timeframe("M", "", group = g3, inline = "a")
c3  = input.color(#8E7CC3, "", group = g3, inline = "a")

gL = "Levels"
showMid  = input.bool(true,  "Midpoint (50%)",       group = gL)
showQtr  = input.bool(true,  "Quarters (25% / 75%)", group = gL)
showEigh = input.bool(false, "Eighths (12.5% / 87.5%)", group = gL,
     tooltip = "The shallowest subdivisions. Useful on wide ranges, cluttered on narrow ones.")

gV = "Style"
showLabels = input.bool(true, "Price labels", group = gV)
lblDetail  = input.string("Short", "Label wording", options = ["Short", "Descriptive"], group = gV,
     tooltip = "Short prints the timeframe code: D High, W Low, M 50%.\nDescriptive spells it out: Previous Day High, Previous Week Low, Previous Month 50%.\n\nShort suits a chart carrying several timeframes at once. Descriptive suits one timeframe, screenshots, and anyone still learning the levels.")
lblSize    = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = gV)
boundWidth = input.int(2, "Boundary line width", minval = 1, maxval = 4, group = gV)
extendBars = input.int(20, "Extend right (bars)", minval = 0, maxval = 200, group = gV)
lookLeft   = input.int(40, "Extend left (bars)",  minval = 0, maxval = 500, group = gV)
dimInner   = input.int(35, "Inner level transparency", minval = 0, maxval = 90, group = gV,
     tooltip = "Fades the midpoint, quarters and eighths so the range boundaries stay dominant.")

// ───────────────────────────────────────────────────────────────────────────
//  DATA
//
//  high[1] / low[1] with lookahead_on is the standard non-repainting idiom for
//  "the previous completed bar of that timeframe". The offset is what makes it
//  safe — without it, lookahead would leak the developing bar's future.
// ───────────────────────────────────────────────────────────────────────────
[h1, l1] = request.security(syminfo.tickerid, tf1, [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h2, l2] = request.security(syminfo.tickerid, tf2, [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h3, l3] = request.security(syminfo.tickerid, tf3, [high[1], low[1]], lookahead = barmerge.lookahead_on)

f_size(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        => size.normal

// Friendly names for the label prefixes
f_tfName(t) =>
    switch t
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "60"  => "1h"
        "120" => "2h"
        "240" => "4h"
        "D"   => "D"
        "W"   => "W"
        "M"   => "M"
        "3M"  => "Q"
        "12M" => "Y"
        => t

// The spelled-out version. "Previous" rather than "Yesterday" on purpose:
// yesterday is Sunday on a Monday, and two days ago after a holiday, and means
// nothing at all if the timeframe input is set to 4h or 6M. "Previous" is
// correct in every one of those cases, and it matches the script's own title.
f_tfLong(t) =>
    switch t
        "1"   => "Previous 1m"
        "3"   => "Previous 3m"
        "5"   => "Previous 5m"
        "15"  => "Previous 15m"
        "30"  => "Previous 30m"
        "60"  => "Previous 1h"
        "120" => "Previous 2h"
        "240" => "Previous 4h"
        "D"   => "Previous Day"
        "W"   => "Previous Week"
        "M"   => "Previous Month"
        "3M"  => "Previous Quarter"
        "12M" => "Previous Year"
        => "Previous " + t

f_prefix(t) => lblDetail == "Descriptive" ? f_tfLong(t) : f_tfName(t)

// ───────────────────────────────────────────────────────────────────────────
//  DRAWING
//
//  Everything is anchored by TIME rather than bar_index. Scrolling left makes
//  TradingView load more history, which renumbers every bar_index — anything
//  pinned to an index would slide out of place. Timestamps never shift.
// ───────────────────────────────────────────────────────────────────────────
var array<line>  lns = array.new_line()
var array<label> lbs = array.new_label()

f_wipe() =>
    while array.size(lns) > 0
        line.delete(array.pop(lns))
    while array.size(lbs) > 0
        label.delete(array.pop(lbs))

f_level(x1, x2, px, txt, col, styl, wid) =>
    array.push(lns, line.new(x1, px, x2, px, xloc = xloc.bar_time, color = col, style = styl, width = wid))
    if showLabels
        array.push(lbs, label.new(x2, px, txt + "  " + str.tostring(px, format.mintick), xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(col, 85), textcolor = col, size = f_size(lblSize)))

f_set(x1, x2, hi, lo, col, name) =>
    if not na(hi) and not na(lo) and hi > lo
        rng  = hi - lo
        soft = color.new(col, dimInner)

        f_level(x1, x2, hi, name + " High", col, line.style_solid, boundWidth)
        f_level(x1, x2, lo, name + " Low",  col, line.style_solid, boundWidth)

        if showMid
            f_level(x1, x2, lo + rng * 0.500, name + " 50%", soft, line.style_dashed, 1)
        if showQtr
            f_level(x1, x2, lo + rng * 0.250, name + " 25%", soft, line.style_dotted, 1)
            f_level(x1, x2, lo + rng * 0.750, name + " 75%", soft, line.style_dotted, 1)
        if showEigh
            f_level(x1, x2, lo + rng * 0.125, name + " 12.5%", soft, line.style_dotted, 1)
            f_level(x1, x2, lo + rng * 0.875, name + " 87.5%", soft, line.style_dotted, 1)

if barstate.islast
    f_wipe()
    ms = timeframe.in_seconds(timeframe.period) * 1000
    xa = time - ms * lookLeft
    xb = time + ms * extendBars

    if on1
        f_set(xa, xb, h1, l1, c1, f_prefix(tf1))
    if on2
        f_set(xa, xb, h2, l2, c2, f_prefix(tf2))
    if on3
        f_set(xa, xb, h3, l3, c3, f_prefix(tf3))

// ── SCALE ANCHOR ──────────────────────────────────────────────────────────
// Lines and labels do not feed TradingView's autoscale. With no plot() of its
// own, an indicator has no price range, so TradingView can hand it a separate
// price scale — and the drawings then sit at an offset from the candles. A
// fully transparent plot of close gives the script a real range and locks it
// to the symbol's scale.
plot(close, "Scale anchor", color = color.new(color.white, 100), editable = false, display = display.pane)
````

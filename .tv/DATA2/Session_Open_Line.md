<!-- tradingview-pine-id: PUB;1fb79081339c4d07b23974027b1ad75f -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session Open Line

Source: https://www.tradingview.com/script/YECX6MR7/

## Description

A price overlay for TradingView (Pine Script v6). A horizontal line at the session's reference level - the previous session's close by default, or the session open - drawn from the first to the last bar of that session, with a label carrying the price change during the session (close vs the reference) - as a percent, as a difference in the instrument currency, or both. Alerts fire when the price crosses the line, and the reference level plus the session change are exposed as hidden series for other scripts.

█ 🧠 WHAT IT SHOWS

For every trading session the script anchors a line at the session's reference level and stretches it to the right as the session progresses:

[pine]
  price
    │                            ╭─╮
    │      reference level       │ │ ╭╮        ← price above the reference
    │   ╭╮                   ╭╮  ╰─╯ ││
    │ ══╪╪═══════════════════╪╪═══════╪╪══ ─►  [ +0.84% ]
    │   ╰╯  ╭╮   ╭╮          ╰╯       ╰╯
    │       ╰╯   ╰╯                       ← price below the reference
    │
    │  ├──────── one session ────────┤├── next session ──
    └────────────────────────────────────────────── time
[/pine]

[*]The line sits at the reference level - the previous session's close (default) or the session open - and never moves vertically.
[*]Its right end follows the current bar until the session ends.
[*]The color of the line depends on the sign of the change: up color when close >= reference level, down color otherwise. It is re-evaluated on every bar, so a session that flips from green to red repaints the whole line.
[*]The whole session is shaded in the same up/down color (on by default, can be turned off).

Reference level

[*]Previous session close (default) - the close of the last bar of the prior session. The change matches the day change quoted against the previous close (the way most quote screens report it), and an opening gap shows up as the distance between the line and the session's first candle.
[*]Session open - the open of the first bar of the session. The change measures only what happened inside the session; there is never a gap between the line and the first candle.

Session detection

A new session is detected with timeframe.change('D') - the trading day boundary as TradingView defines it for the symbol. That is deliberately not "midnight": it follows the instrument's own session definition, so futures sessions that cross midnight are handled correctly (the line starts at the session boundary, not at 00:00).

Why a box, not bgcolor()

The session highlight is drawn as one box per session rather than bgcolor(). bgcolor() paints a single bar and cannot be repainted afterwards, so a session that flips sign would end up striped. A box spans the whole session and keeps a single color that is corrected on every bar. Box extend only works on the time axis, so the vertical coverage comes from the box bounds: the highest high and lowest low of the loaded data, padded by 100x that range above and below. On the last bar every box is brought to the final bounds, so sessions drawn while less data was loaded get the same coverage.

Why not simply 1e17 / -1e17: TradingView silently skips boxes whose bounds lie extremely far from the price scale (on an instrument near 85, bounds of +-1e8 still draw while +-1e9 do not). Such boxes exist - they show up in the object tree - but never render, so the highlight looks like it is not working at all.

█ 🏷️ THE CHANGE LABEL

The label is colored by the sign of the change and sits on a fully transparent background. Two checkboxes decide what it carries:

[*]Show percent change (default on) - the change as a percent of the reference level, formatted as +0.84% / -1.12% (always signed, two decimals).
[*]Show change in instrument currency (default off) - the change as a price difference (close - reference level), formatted with the symbol's tick precision (format.mintick) and suffixed with syminfo.currency, e.g. +12.50 USD. For symbols without a quote currency the suffix is omitted.

With both on the label reads +0.84% (+12.50 USD); with both off no label is drawn at all - only the line (and the optional highlight) remains. For a reference level at or below zero (possible on futures spreads) the percent is undefined - the label falls back to the price difference, and the up/down color always follows the sign of the difference, which stays meaningful at any price.

Percent position decides where it sits, and the choice applies the same way to completed sessions and to the ongoing one:

[*]Behind the line (default) - anchored on its left edge (label.style_label_left), at the reference level, right of the line end, as if continuing the line.
[*]Above the line - anchored at its bottom-right corner (label.style_label_lower_right), so the text sits over the end of the line and does not stick out past the session end.
[*]Below the line - anchored at its top-right corner (label.style_label_upper_right), so the text hangs under the end of the line, again inside the session.

During the ongoing session the label follows the end of the line and updates on every bar; once the session ends it stays at the last bar with the final value.

█ 🛠️ KEY PARAMETERS

General

[*]Reference level (default Previous session close) - Previous session close / Session open, described above.
[*]Show percent change (default on) - percent of the reference level in the label.
[*]Show change in instrument currency (default off) - price difference in the instrument currency in the label.

Appearance

[*]Up color (default #26A69A) - line and label color when the session is up.
[*]Down color (default #EF5350) - line and label color when the session is down.
[*]Line style (default Solid) - Solid / Dashed / Dotted.
[*]Line width (default 1) - range 1-4.
[*]Text size (default Small) - Auto / Tiny / Small / Normal / Large.
[*]Percent position (default Behind the line) - Above the line / Below the line / Behind the line, described above.

Session highlight

[*]Highlight the whole session (default on) - fills the entire session with a single color, decided by where the price stands against the reference level.
[*]Highlight up color (default #26A69A at 90% transparency).
[*]Highlight down color (default #EF5350 at 90% transparency).

█ 📈 HOW TO READ IT

[*]The line is a reference level, not a signal. Trading above it means buyers have controlled the day so far; below it, sellers have.
[*]Reclaims and rejections at the line are the interesting part - price returning to the level and being pushed away often marks who is defending the day.
[*]With the previous-session-close reference (default) the line doubles as the gap-fill level: a session that opens with a gap and later crosses the line has closed that gap.
[*]The label value gives an instant sense of the session's magnitude without measuring anything by hand, and the sign color makes a flip visible at a glance. The percent is comparable across instruments; the currency difference maps directly to points or ticks on the symbol you trade.
[*]With the session highlight on, a screen full of alternating green and red blocks makes runs of consecutive up or down sessions obvious.

█ 🔔 ALERTS

[*]Cross above the reference level - the price crossed the current session's line from below.
[*]Cross below the reference level - the price crossed the current session's line from above.

Those are exactly the reclaim/rejection moments described above (with the default reference: the gap-fill / day-flip moments). The first bar of a session - where the line jumps to the new reference - never fires either alert. Crosses are evaluated on close, so on the live candle a cross can appear and un-cross before the candle closes; set the alert trigger to Once Per Bar Close if you only want confirmed crosses.

█ 📤 HIDDEN SERIES

The script exposes two hidden series, visible in the Data Window and usable as an external source in other indicators and strategies (any input.source field):

[*]Reference level - the level the line sits at: the previous session's close (default) or the session open.
[*]Session change % - the session change as a percent of the reference level.

█ ⛔ LIMITATIONS

[*]Intraday timeframes only. On D and above every bar is its own session, so the script draws nothing and instead shows a hint table in the top-right corner: Session Open Line: the indicator works on intraday timeframes.
[*]Drawing objects are capped at 500 lines, 500 labels, and 500 boxes - older sessions drop off the left side of the chart.
[*]Both values are computed from close against the reference level, so during the ongoing session they move with every tick and only become final at the session close.
[*]The first session in the loaded history starts at the first loaded bar, which is not necessarily the true session start. With the default reference (previous session close) it has no prior close at all, so it draws nothing; with the session-open reference its "open" (and therefore its change) can be off. Every later session is exact.

© Piotr Kowalski "piecioshka". License: Mozilla Public License 2.0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Piotr Kowalski "piecioshka"
// Docs (EN): https://github.com/piecioshka/tradingview-pine-scripts/blob/main/indicators/overlays/session-open-line/session-open-line.md
// Docs (PL): https://github.com/piecioshka/tradingview-pine-scripts/blob/main/indicators/overlays/session-open-line/session-open-line.pl.md

//@version=6
// Draws a horizontal line at the session's reference level - from the first
// to the last bar of the session. By default the reference is the previous
// session's close, so the change matches the day change quoted against the
// prior close and opening gaps become visible; the 'Reference level' input
// switches it to the session open, measuring only what happened inside the
// session. A label shows the price change during the session (close vs the
// reference level) as a percent, as a difference in the instrument currency,
// or both - each part has its own checkbox. The 'Percent
// position' input decides where the label sits - above or below the line, or
// behind its end - and the choice applies consistently to completed sessions
// and to the ongoing one. During the ongoing session the value updates on
// every bar. Line and label colors depend on the sign of the change - up,
// down, or unchanged when the close sits exactly at the reference level - and
// the whole session is shaded with the same color (can be turned off). Alerts
// fire when the price crosses the line in either direction, and the
// reference level plus the session change (%) are exposed as hidden series -
// other scripts can use them as external sources. Works on intraday
// timeframes - on D and above every bar is its own session, so the indicator
// only shows a hint.
indicator('Session Open Line', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

refLevelName = input.string('Previous session close', 'Reference level', options = ['Previous session close', 'Session open'], group = 'General', tooltip = 'The level the line sits at and the change is measured from. Previous session close (default): the close of the last bar of the previous session - the change matches the day change quoted against the prior close, and an opening gap shows up as the distance between the line and the first candle. Session open: the open of the first bar of the session - the change measures only what happened inside the session. The first session in the loaded history has no previous close, so in the default mode it gets no line.')
showPct = input.bool(true, 'Show percent change', group = 'General', tooltip = 'Shows the session change as a percent of the reference level, e.g. +0.84%.')
showAbs = input.bool(false, 'Show change in instrument currency', group = 'General', tooltip = 'Shows the session change as a price difference (close minus the reference level) in the currency of the instrument, e.g. +12.50 USD. With both checkboxes on the label reads +0.84% (+12.50 USD).')
GRP = 'Appearance'
upColor = input.color(#26A69A, 'Up color', group = GRP)
downColor = input.color(#EF5350, 'Down color', group = GRP)
flatColor = input.color(#787B86, 'Unchanged color', group = GRP, tooltip = 'Used when the close sits exactly at the reference level - neither a rise nor a fall. Happens on the first bar of a session opening at the previous close, and on illiquid instruments.')
lineStyleName = input.string('Solid', 'Line style', options = ['Solid', 'Dashed', 'Dotted'], group = GRP)
lineWidth = input.int(1, 'Line width', minval = 1, maxval = 4, group = GRP)
textSizeName = input.string('Small', 'Text size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large'], group = GRP)
pctPositionName = input.string('Behind the line', 'Percent position', options = ['Above the line', 'Below the line', 'Behind the line'], group = GRP, tooltip = 'Above the line: the value sits over the end of the line. Below the line: the value hangs under the end of the line. Behind the line: the value sits at the reference level, right of the line end, as if continuing it. The choice applies to both completed and ongoing sessions.')
GRP_BG = 'Session highlight'
showBg = input.bool(true, 'Highlight the whole session', group = GRP_BG, tooltip = 'Fills the entire session with a single color, decided by where the price stands against the reference level.')
bgUpColor = input.color(color.new(#26A69A, 90), 'Highlight up color', group = GRP_BG)
bgDownColor = input.color(color.new(#EF5350, 90), 'Highlight down color', group = GRP_BG)
bgFlatColor = input.color(color.new(#787B86, 90), 'Highlight unchanged color', group = GRP_BG)

usePrevClose = refLevelName == 'Previous session close'

lineStyle = switch lineStyleName
    'Dashed' => line.style_dashed
    'Dotted' => line.style_dotted
    => line.style_solid

textSize = switch textSizeName
    'Auto' => size.auto
    'Tiny' => size.tiny
    'Normal' => size.normal
    'Large' => size.large
    => size.small

// One position for every label the indicator draws — completed sessions and
// the ongoing one alike.
pctStyle = switch pctPositionName
    'Above the line' => label.style_label_lower_right
    'Below the line' => label.style_label_upper_right
    => label.style_label_left

// Both checkboxes off means no label at all.
showLabel = showPct or showAbs

// syminfo.currency is empty for some symbols (e.g. indices without a quote
// currency) - then the difference is shown as a bare number.
currencySuffix = not na(syminfo.currency) and syminfo.currency != '' ? ' ' + syminfo.currency : ''

fmtPct(float pct) =>
    (pct >= 0 ? '+' : '') + str.tostring(pct, '0.00') + '%'

fmtAbs(float delta) =>
    (delta >= 0 ? '+' : '') + str.tostring(delta, format.mintick) + currencySuffix

// Percent first, the currency difference in parentheses - or either one
// alone. An undefined percent (reference level at or below zero) falls back
// to the price difference, which stays meaningful at any price.
fmtChange(float delta, float pct) =>
    showPct and showAbs and not na(pct) ? fmtPct(pct) + ' (' + fmtAbs(delta) + ')' : showPct and not na(pct) ? fmtPct(pct) : fmtAbs(delta)

// label_lower_right - anchor at the bottom-right corner, the text sits above
// the line and does not stick out past the session end. label_upper_right -
// anchor at the top-right corner, the text hangs below the line, again inside
// the session. label_left - anchor on the left edge, the text sits at the
// reference level, to the right of the line end, as if continuing the line.
newLabel(int x, float y, float delta, float pct, color col, string sizeName, string labelStyle) =>
    label.new(x, y, fmtChange(delta, pct), xloc = xloc.bar_index, style = labelStyle, textcolor = col, color = color.new(color.black, 100), size = sizeName)

// Vertical bounds of the session highlight. TradingView silently skips boxes
// whose top/bottom lie extremely far from the price scale (measured on an
// instrument near 85: bounds of +-1e8 still draw, +-1e9 do not), so absurd
// constants like 1e17 produce boxes that exist but never render. Instead
// the bounds follow the price range of the loaded data - 100x that range
// above and below covers the full height of the pane at any realistic zoom
// while staying far inside the renderer's limits.
BG_PAD = 100.0
var float dataHigh = na
var float dataLow = na
if not na(high) and not na(low)
    dataHigh := na(dataHigh) ? high : math.max(dataHigh, high)
    dataLow := na(dataLow) ? low : math.min(dataLow, low)
bgPad = math.max(dataHigh - dataLow, syminfo.mintick) * BG_PAD
bgTop = dataHigh + bgPad
bgBottom = dataLow - bgPad

// time('D') changes on the first bar of the trading day, so it also works
// for sessions crossing midnight (e.g. futures).
newSession = timeframe.change('D')

var line ln = na
var label lb = na
var box bg = na
var float sessionRef = na

// The reference level of the session: its own open, or the close of the
// previous session (close[1] on the session's first bar). On the very first
// loaded bar close[1] is na - in 'Previous session close' mode the first
// session has no reference, so it draws nothing.
if timeframe.isintraday and (newSession or barstate.isfirst)
    sessionRef := usePrevClose ? close[1] : open
    lb := na
    if not na(sessionRef)
        ln := line.new(bar_index, sessionRef, bar_index, sessionRef, xloc = xloc.bar_index, color = flatColor, style = lineStyle, width = lineWidth)
        // One box per session instead of bgcolor(), which paints a single bar
        // and cannot be repainted later - a box spans the whole session and
        // keeps one color, corrected on every bar of that session. Box
        // 'extend' works on the time axis only, so the vertical coverage
        // comes from the bgTop/bgBottom bounds.
        bg := showBg ? box.new(bar_index, bgTop, bar_index, bgBottom, xloc = xloc.bar_index, border_color = color.new(color.black, 100), bgcolor = bgFlatColor) : na
    else
        ln := na
        bg := na

// The sign of the change comes from the price difference, not from the
// percent - for a reference level at or below zero (possible on futures
// spreads) the percent flips sign or loses meaning, the difference never
// does.
delta = close - sessionRef
pct = sessionRef > 0 ? delta / sessionRef * 100 : na
// Three states, not two: a close exactly at the reference level is neither a
// rise nor a fall and gets its own neutral color instead of being folded into
// one of them.
col = delta > 0 ? upColor : delta < 0 ? downColor : flatColor

if timeframe.isintraday and not na(ln)
    line.set_x2(ln, bar_index)
    line.set_color(ln, col)
    if not na(bg)
        box.set_right(bg, bar_index)
        box.set_bgcolor(bg, delta > 0 ? bgUpColor : delta < 0 ? bgDownColor : bgFlatColor)
    // The label follows the end of the line and updates on every bar of
    // the session.
    if showLabel
        if na(lb)
            lb := newLabel(bar_index, sessionRef, delta, pct, col, textSize, pctStyle)
        else
            label.set_x(lb, bar_index)
            label.set_text(lb, fmtChange(delta, pct))
            label.set_textcolor(lb, col)

if timeframe.isintraday
    // Boxes of earlier sessions were created while less data was loaded, so
    // their bounds are narrower - on the last bar bring every box to the
    // final bounds. Runs only when the bounds actually change.
    var float sweptTop = na
    if barstate.islast and (na(sweptTop) or bgTop != sweptTop)
        sweptTop := bgTop
        for b in box.all
            box.set_top(b, bgTop)
            box.set_bottom(b, bgBottom)
else
    if barstate.islast
        var table hint = table.new(position.top_right, 1, 1)
        table.cell(hint, 0, 0, 'Session Open Line: the indicator works on intraday timeframes', text_color = color.gray, text_size = size.small)

// A cross is only meaningful against the current session's line, so the
// first bar of a session - where the line jumps to the new reference - is
// excluded.
crossUp = ta.crossover(close, sessionRef)
crossDown = ta.crossunder(close, sessionRef)
alertOk = timeframe.isintraday and not newSession
alertcondition(alertOk and crossUp, 'Cross above the reference level', 'Price crossed above the session reference level (session open or previous session close)')
alertcondition(alertOk and crossDown, 'Cross below the reference level', 'Price crossed below the session reference level (session open or previous session close)')

// Hidden series - rows in the Data Window and external sources for other
// scripts (any input.source field): the reference level and the session
// change as a percent.
plot(timeframe.isintraday ? sessionRef : na, 'Reference level', display = display.data_window, editable = false)
plot(timeframe.isintraday ? pct : na, 'Session change %', display = display.data_window, editable = false)
````

<!-- tradingview-pine-id: PUB;9f15da1ee63d46fdb701ef5c7aca15cb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# R-Level Targets

Source: https://www.tradingview.com/script/sBrjZ8Am-R-Level-Targets/

## Description

R-Level Targets — Drag-to-Set Entry, Stop & R-Multiple Targets
Draws entry, stop, and R-multiple target lines from two price levels you set by dragging lines directly on the chart — no settings dialog required, though typing exact values into settings works too. Direction (Long/Short) is inferred automatically from whether the stop is above or below entry.

How it works

[*]Add the indicator, then drag the Entry and Stop lines to your levels (or type them into the settings).
[*]Risk = distance from entry to stop. Each R level is drawn at a multiple of that risk, projected in the direction implied by your stop placement.
[*]The stop-to-entry range is shaded as a loss zone; each R interval above/below entry is shaded a progressively deeper profit zone, echoing TradingView's built-in Long/Short Position tool.
[*]Lines run from today's session open to a label column on the right — they don't stretch back across every session loaded on the chart.
[*]A small "Current R" value is available in the Data Window (hover the chart) so you can track live unrealized R without cluttering the chart itself.

Inputs

[*]Position — Entry price, Stop price, label offset (bars), and a snap increment so a hand-dragged line lands on a real tradeable price instead of a stray decimal.
[*]R Levels — a free-form comma-separated list (e.g. 1, 1.5, 2), any order, up to 10 levels, plus a "Target R" value that gets highlighted separately from the rest.
[*]Display — toggle tick count and $ risk-per-contract on the Stop label.
[*]Colors — every line and fill color is configurable.

Notes / limitations

[*]This is a manual planning tool, not an auto-trader: Pine Script has no access to your broker's live fills or position events, even through TradingView's Trading Panel, so nothing here executes or tracks real trades — it's a visual guide you set yourself.
[*]Custom scripts can't add themselves to TradingView's drawing-tools sidebar, so input.price() (a draggable line in settings) is used as the closest equivalent to a drawing tool.
[*]Defaults on add (23500 / 23475) are just a starting point sized for NQ/MNQ — update the levels for your instrument, or drag/type them each trade.

Disclaimer
This script is a visual planning aid and does not constitute financial advice. It does not place trades or connect to any brokerage account.

---

## Source Code

````pine
// R-Level Targets — draws entry, stop, and R-multiple target lines from two
// price levels you set by DRAGGING lines directly on the chart — no
// settings dialog required, though typing exact values into settings works
// too. Direction (Long/Short) is inferred automatically from whether the
// stop is below or above entry.
//
// Lines run from today's session open to the label column (not stretched
// across every prior session loaded on the chart). The stop-to-entry band
// is shaded (loss zone), each R interval is shaded a progressively deeper
// zone color, and a right-edge label names each line — same visual language
// as TradingView's built-in Long/Short Position tool.
//
// This can't read your broker/account automatically — Pine Script has no
// access to live fill or position events from a connected trading account,
// even through TradingView's own Trading Panel. Custom indicators also
// can't add themselves to TradingView's drawing-tools sidebar (that's
// reserved for TradingView's own tools) — input.price() is the closest
// equivalent: a line you drag right on the chart instead of a dialog.
//
// Defaults on add: Entry starts at 23500 and Stop at 23475 (NQ/MNQ range,
// 100 ticks apart at the 0.25 default rounding) — fixed literals, chosen to
// land near the futures range this was set up for. input.price()'s defval
// must be a hardcoded constant (Pine can't default it to a live series like
// `close`), so these numbers won't drift or auto-track price; update them
// below as your typical trading range changes, or just drag/type the real
// level each trade like normal.
//
// R levels are a free-form comma-separated list (e.g. "1, 1.5, 2") — type
// only the multiples you want drawn, in any order, up to 10. Whichever one
// matches "Target R" gets highlighted as the target line; the rest use the
// plain R-level color. Whether the Stop label shows tick count / $ risk per
// contract, and every line/fill color, are all configurable in settings.
//
// Matches the same R-level idea tracked in the Trade Log journal, so what
// you see here lines up with what you'd check off in the app afterward.
//
// Setup: TradingView -> Pine Editor (bottom panel) -> paste this in ->
// "Add to chart".
//@version=6
indicator('R-Level Targets', overlay = true, max_lines_count = 50, max_labels_count = 30)

// ── Position ────────────────────────────────────────────────────────────
entryInput = input.price(23500.0, title = 'Entry Price', tooltip = 'Drag this line to your entry price, or type it into settings.', group = 'Position')
stopInput = input.price(23475.0, title = 'Stop Price', tooltip = 'Drag this line to your stop price, or type it into settings. Direction is inferred: stop below entry = Long, stop above entry = Short.', group = 'Position')
labelOffset = input.int(10, title = 'Label offset in bars (negative = left of current candle, positive = right)', group = 'Position')
roundIncrement = input.float(0.25, title = 'Snap entry/stop to nearest', step = 0.01, minval = 0.0, tooltip = 'Dragging a line by hand can land on odd fractional prices your instrument doesn\'t actually trade at. Entry/Stop (and everything computed from them) get snapped to the nearest multiple of this. Set to 0 to disable.', group = 'Position')

// ── R Levels ───────────────────────────────────────────────────────────
rLevelsInput = input.string('1, 1.25, 1.5, 2, 3', title = 'R levels (comma-separated)', tooltip = 'Which R multiples to draw, e.g. "1, 1.5, 2". Any count, any order, up to 10.', group = 'R Levels')
targetMultInput = input.float(1.5, title = 'Target R (highlighted line — must match one of the levels above)', step = 0.05, group = 'R Levels')

// ── Display ────────────────────────────────────────────────────────────
showTicks = input.bool(true, 'Show tick count on Stop label', group = 'Display')
showDollarRisk = input.bool(true, 'Show $ risk per contract on Stop label', group = 'Display')

// ── Colors ─────────────────────────────────────────────────────────────
entryColor = input.color(color.gray, 'Entry line', group = 'Colors')
stopColor = input.color(color.red, 'Stop line', group = 'Colors')
rLevelColor = input.color(color.green, 'R level lines', group = 'Colors')
targetColor = input.color(color.lime, 'Target level line', group = 'Colors')
lossFillColor = input.color(color.red, 'Loss zone fill', group = 'Colors')
profitFillColor = input.color(color.green, 'Profit zone fill', group = 'Colors')

roundTo(price) =>
    roundIncrement <= 0 ? price : math.round(price / roundIncrement) * roundIncrement

fmt(price) =>
    str.tostring(price, '#.##')

// Parses "1, 1.25, 1.5" into a sorted float array, skipping blank/invalid
// entries, capped at 10 so the drawing budget below stays bounded.
parseLevels(txt) =>
    arr = array.new_float()
    parts = str.split(txt, ',')
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1 by 1
            s = str.trim(array.get(parts, i))
            if str.length(s) > 0
                v = str.tonumber(s)
                if not na(v)
                    array.push(arr, v)
    array.sort(arr, order.ascending)
    while array.size(arr) > 10
        array.pop(arr)
    arr

entryPrice = roundTo(entryInput)
stopPrice = roundTo(stopInput)

isLong = entryPrice > stopPrice
risk = math.abs(entryPrice - stopPrice)
// Dollar risk for one contract/share at the current stop distance.
// syminfo.pointvalue is the $ value of a 1-point move for one contract —
// correct for futures as-is; for stocks it's 1, so this becomes $/share.
dollarRisk = risk * syminfo.pointvalue
riskTicks = syminfo.mintick > 0 ? risk / syminfo.mintick : na

levelPrice(mult) =>
    isLong ? entryPrice + mult * risk : entryPrice - mult * risk

// Track the bar index where today's session began — lines/zones span from
// there to the label column only, instead of stretching across every prior
// session loaded on the chart (which is all hline() can do).
var int sessionStartBar = na
if session.isfirstbar
    sessionStartBar := bar_index
    sessionStartBar

// ── Lines, shaded zones, and labels — all redrawn only on the last bar so
// they track the current session/price without cluttering history. ─────
var line lnEntry = na
var line lnStop = na
var linefill fillStop = na
var label lblEntry = na
var label lblStop = na
var array<line> lnLevels = array.new_line()
var array<label> lblLevels = array.new_label()
var array<linefill> fillLevels = array.new_linefill()

if barstate.islast and not na(sessionStartBar)
    line.delete(lnEntry)
    line.delete(lnStop)
    linefill.delete(fillStop)
    label.delete(lblEntry)
    label.delete(lblStop)
    // while/pop instead of `for i = 0 to array.size(x) - 1`: when an array is
    // empty, size - 1 is -1, and Pine's for-loop silently flips to descending
    // instead of skipping — it still runs once for i=0 and errors on an
    // empty array. while naturally does zero iterations when already empty.
    while array.size(lnLevels) > 0
        line.delete(array.pop(lnLevels))
    while array.size(lblLevels) > 0
        label.delete(array.pop(lblLevels))
    while array.size(fillLevels) > 0
        linefill.delete(array.pop(fillLevels))

    // On instruments that trade close to 24h (NQ, ES, etc.), session.isfirstbar
    // can fail to reset daily, leaving sessionStartBar stuck arbitrarily far
    // in the past — reaching back that far errors out ("historical offset
    // beyond buffer limit") on fine timeframes. Cap how far x1 is allowed to
    // reach so the line always stays inside a safe, always-available window,
    // regardless of whether the session actually reset.
    x1 = math.max(sessionStartBar, bar_index - 400)
    xLbl = bar_index + labelOffset
    // Lines run all the way to the label column (instead of stopping at the
    // current bar) so each R-line visually connects to its label.
    x2 = math.max(bar_index, xLbl)

    lnEntry := line.new(x1, entryPrice, x2, entryPrice, xloc = xloc.bar_index, extend = extend.none, color = entryColor, style = line.style_dotted, width = 1)
    lnStop := line.new(x1, stopPrice, x2, stopPrice, xloc = xloc.bar_index, extend = extend.none, color = stopColor, style = line.style_dashed, width = 2)
    fillStop := linefill.new(lnEntry, lnStop, color.new(lossFillColor, 90))

    // Labels show the actual rounded price we computed — not the raw
    // dragged input value, which TradingView's settings field displays with
    // whatever messy decimal precision the drag landed on and which Pine
    // has no way to clean up (a script can't write back into an input).
    stopDetails = array.new_string()
    if showTicks
        array.push(stopDetails, str.tostring(riskTicks, '#') + ' ticks')
    if showDollarRisk
        array.push(stopDetails, '$' + str.tostring(dollarRisk, '#.##') + '/contract')
    stopText = 'Stop  ' + fmt(stopPrice) + (array.size(stopDetails) > 0 ? '  (' + array.join(stopDetails, ', ') + ')' : '')

    lblEntry := label.new(xLbl, entryPrice, 'Entry  ' + fmt(entryPrice), style = label.style_label_left, color = color.new(entryColor, 80), textcolor = entryColor, size = size.large)
    lblStop := label.new(xLbl, stopPrice, stopText, style = label.style_label_left, color = color.new(stopColor, 80), textcolor = stopColor, size = size.large)

    levels = parseLevels(rLevelsInput)
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1 by 1
            m = array.get(levels, i)
            p = levelPrice(m)
            isTarget = math.abs(m - targetMultInput) < 0.0001
            col = isTarget ? targetColor : rLevelColor
            st = isTarget ? line.style_solid : line.style_dashed
            wd = isTarget ? 2 : 1
            prevLine = i == 0 ? lnEntry : array.get(lnLevels, i - 1)

            ln = line.new(x1, p, x2, p, xloc = xloc.bar_index, extend = extend.none, color = col, style = st, width = wd)
            array.push(lnLevels, ln)

            zoneTransparency = math.max(50, 92 - i * 5)
            fl = linefill.new(prevLine, ln, color.new(profitFillColor, zoneTransparency))
            array.push(fillLevels, fl)

            labelText = str.tostring(m) + 'R' + (isTarget ? ' — target' : '') + '  ' + fmt(p)
            lbl = label.new(xLbl, p, labelText, style = label.style_label_left, color = color.new(col, 80), textcolor = col, size = size.large)
            array.push(lblLevels, lbl)

// Live unrealized R, visible by hovering the chart or opening the data
// window (not plotted on the chart itself, to keep it uncluttered).
currentR = risk > 0 ? (isLong ? close - entryPrice : entryPrice - close) / risk : na
plot(currentR, title = 'Current R', display = display.data_window)
````

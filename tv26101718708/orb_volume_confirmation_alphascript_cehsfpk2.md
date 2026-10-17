# ORB + Volume Confirmation | AlphaScript

- url: https://www.tradingview.com/script/CEhSfPK2-ORB-Volume-Confirmation-AlphaScript/
- type: indicator
- pine_id: PUB;cc6b84e9fa40446d85ba0e727e29fb0e
- version: 1.0

## Description

[b]ORB + Volume Confirmation filters the opening range breakout through the one thing most ORB tools ignore:[/b] whether anyone actually showed up for the move. 

Every breakout is checked against relative volume, and the ones that fail the check get marked right on your chart — hollow, gray, labeled. For the first time you don't just see the breakouts you'd take. You see the ones that would have taken you.

[b]🧠 Concept[/b]

[b]The number one complaint about opening range breakout systems is false breakouts[/b] — price pokes through the range, triggers the entry, and immediately reverses. But most false breakouts share a fingerprint: they happen on thin volume. 
A genuine initiative break is an auction event; participants commit size to push price out of balance, and that commitment is visible in the tape before the follow-through confirms it. A breakout on quiet volume isn't initiative — it's drift, and drift beyond a boundary gets sold back inside.

The fix isn't a better range. It's asking one question at the moment of the break: is this bar's volume abnormal for this moment of the day? If yes, the break is confirmed. If no, it's flagged as exactly what it is — a breakout that crossed the line without the fuel to hold it.

[b]🔍 What it does[/b]
Builds the opening range from the first N minutes of your session (5/15/30/60, timezone configurable) and draws it as a clean box that releases price after a set number of bars, with the range high and low continuing as level rays across the session.
Every close beyond the range is then sorted into one of two categories:

[b]Confirmed breakout[/b] — close beyond the range AND relative volume at or above your threshold (default 1.5×). Marked with a bold signal label showing the exact volume multiple ("LONG BREAK · 2.5× VOL"), plus projected targets at 0.5×, 1.0×, 1.5×, and 2.0× the range height.

[b]Unconfirmed breakout[/b] — price crossed, volume didn't. Marked hollow and gray with its actual reading ("no vol 1.1×"). These marks are the teaching layer of the entire tool: scroll back through any month of sessions and count how many of the gray triangles reversed. That's the tuition a naked ORB system charges.

[b]Two volume engines are included.[/b] Rolling SMA compares the bar against recent average volume — simple, active immediately. Time-of-Day (adaptive) compares each bar against the average volume at that same minute of the day across recent sessions — the stricter, more honest read, because it knows the open is always loud and refuses to be impressed by it.

[b]⚙️ How it works[/b]
A breakout is confirmed only on a full bar close beyond the range — wicks don't count, and nothing repaints intrabar. One confirmed signal per direction per session, so a chop day can't spam your chart or your alerts.

Signals are only valid within a configurable window after the range completes (default 3 hours). A late-afternoon "break" of the morning range is a different trade — this tool refuses to pretend otherwise.

Relative volume is computed against a baseline that never includes the current bar, zero-volume bars can never confirm, and the session logic survives date rollovers, holiday sessions, and the Sunday futures open. Intraday charts only, at or below the range duration — the script enforces this rather than silently drawing nonsense.

[b]Targets are fully configurable:[/b] independent colors per direction, line style, width, transparency, labels — and an option to keep target levels from previous sessions on the chart (depth of your choosing), turning the tool into a study of how price respects old range projections.

[b]📈 How to use it[/b]

[b]The default configuration is built for US index futures:[/b] 15-minute opening range, New York 09:30 session, 1.5× volume threshold on a 1–5 minute chart.

Start by doing nothing. Load it, scroll back twenty sessions, and compare the confirmed signals against the gray ones. The threshold isn't a magic number — it's a dial between selectivity and opportunity, and the chart will show you where your market and timeframe want it. Index futures generally respect 1.5×; forex tick volume tends to run flatter, so 1.2–1.3× is a more realistic starting point there.

[b]The volume multiple printed on each signal is information, not decoration:[/b] 
a 3× break and a 1.6× break both confirm, but they are not the same trade.
[b]Three alerts are included:[/b] confirmed long, confirmed short, and unconfirmed touch (off by default — turn it on if you want to be told when a trap is forming). Recommended setting: "Once per bar close."

[b]📝 Notes[/b]
A decision-support tool, not a strategy. Volume confirmation filters breakouts — it doesn't guarantee them. Confirmed breaks fail too, just less often than the ones nobody paid for. Always apply your own risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaScript

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  ORB + Volume Confirmation | AlphaScript
//  Opening Range Breakout where breakouts only qualify on abnormal volume.
//  Confirmed breaks = close beyond OR extreme AND RVOL >= threshold.
//  Unconfirmed breaks (price crosses, volume doesn't) are marked separately.
//  Intraday-only. Volume baseline: adaptive time-of-day (per-slot EMA across
//  sessions) with automatic rolling-SMA fallback during warmup.
// ═══════════════════════════════════════════════════════════════════════════
indicator("ORB + Volume Confirmation | AlphaScript", shorttitle="ORB+VOL", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grpSess   = "Session"
grpOR     = "Opening Range"
grpVol    = "Volume Confirmation"
grpTgt    = "Targets"
grpVis    = "Visuals"
grpAlert  = "Alerts"

sessStr    = input.session("0930-1600", "Session (start-end)", group = grpSess, tooltip = "Session window in the selected timezone. OR builds from session start.")
tzInput    = input.string("America/New_York", "Timezone", group = grpSess, options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "UTC", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Australia/Sydney"])

orMinutes  = input.int(15, "Opening Range Duration (min)", minval = 1, maxval = 240, group = grpOR, tooltip = "Any duration in minutes. Common choices: 5, 15, 30, 60. Must be >= your chart timeframe.")

rvolThresh = input.float(1.5, "RVOL Threshold", minval = 1.0, maxval = 3.0, step = 0.1, group = grpVol, tooltip = "Breakout confirmed only when bar volume / baseline >= this value.")
baseMode   = input.string("Rolling SMA", "Volume Baseline Mode", options = ["Time-of-Day (adaptive)", "Rolling SMA"], group = grpVol, tooltip = "Rolling SMA: bar volume vs recent average — simple, works immediately. Time-of-Day: compares each bar to average volume at the SAME time of day over recent sessions — stricter and more honest near the open, needs several sessions of chart history to activate.")
volLookback = input.int(20, "Volume Baseline Lookback", minval = 5, maxval = 200, group = grpVol, tooltip = "Rolling SMA mode: bars. Time-of-Day mode: sessions (EMA-weighted).")
minSessions = input.int(5, "Min Sessions Before Time-of-Day Kicks In", minval = 2, maxval = 20, group = grpVol)

showTargets  = input.bool(true, "Show Target Lines", group = grpTgt)
tgtColLong   = input.color(color.new(#00c896, 0), "Long Target Color", group = grpTgt)
tgtColShort  = input.color(color.new(#ff4d6d, 0), "Short Target Color", group = grpTgt)
tgtStyleIn   = input.string("Dashed", "Target Line Style", options = ["Solid", "Dashed", "Dotted"], group = grpTgt)
tgtWidthIn   = input.int(1, "Target Line Width", minval = 1, maxval = 4, group = grpTgt)
tgtTransp    = input.int(45, "Target Line Transparency", minval = 0, maxval = 90, group = grpTgt)
tgtShowLbl   = input.bool(true, "Show Target Labels", group = grpTgt)
tgtKeepPrev  = input.bool(false, "Keep Previous Session Targets", group = grpTgt, tooltip = "When on, target levels from prior sessions stay on the chart (frozen where they ended) instead of being wiped at the next session open. Useful for seeing how price respects old OR-projected levels.")
tgtKeepN     = input.int(3, "Previous Sessions to Keep", minval = 1, maxval = 30, group = grpTgt, tooltip = "How many past sessions of targets stay visible. Older sessions are removed automatically.")
tgtLblSize   = input.string("Small", "Target Label Size", options = ["Tiny", "Small", "Normal"], group = grpTgt)
sigWindowHrs = input.float(3.0, "Signal Window After OR (hours)", minval = 0.5, maxval = 12, step = 0.5, group = grpOR, tooltip = "Breakout signals are only valid within this many hours after the OR completes. Late-day breaks of the morning range are a different trade — suppressed by default.")
showUnconf   = input.bool(true, "Show Unconfirmed Breakouts", group = grpVis)
showMidline  = input.bool(true, "Show OR Midline", group = grpVis)
orExtendBars = input.int(10, "OR Box Extension (bars)", minval = 0, maxval = 100, group = grpVis, tooltip = "How many bars past OR completion the box extends before freezing. 0 = freeze immediately at OR end.")

// Premium palette — muted, low-noise defaults
colBull      = input.color(#00c896, "Bull Accent", group = grpVis)
colBear      = input.color(#ff4d6d, "Bear Accent", group = grpVis)
colNeutral   = input.color(#8b93a7, "Neutral / Unconfirmed", group = grpVis)
colORFill    = input.color(color.new(#1de9b6, 94), "OR Box Fill", group = grpVis)
colORBorder  = input.color(color.new(#1de9b6, 55), "OR Box Border", group = grpVis)

alertConfLong   = input.bool(true,  "Alert: Confirmed Long Breakout", group = grpAlert)
alertConfShort  = input.bool(true,  "Alert: Confirmed Short Breakout", group = grpAlert)
alertUnconf     = input.bool(false, "Alert: Unconfirmed Touch", group = grpAlert)

// ─────────────────────────────────────────────
//  GUARDS: intraday-only
// ─────────────────────────────────────────────
if timeframe.isdwm or timeframe.in_seconds() > 60 * orMinutes
    runtime.error("ORB+VOL is intraday-only and the chart timeframe must be <= the Opening Range duration. Use a 1–" + str.tostring(orMinutes) + " minute chart.")

// ─────────────────────────────────────────────
//  SESSION / DATE LOGIC
// ─────────────────────────────────────────────
inSession   = not na(time(timeframe.period, sessStr, tzInput))
newSession  = inSession and not inSession[1]

var int sessionOpenTime = na
if newSession
    sessionOpenTime := time

orEndTime   = sessionOpenTime + orMinutes * 60 * 1000
inORWindow  = inSession and not na(sessionOpenTime) and time < orEndTime
orComplete  = inSession and not na(sessionOpenTime) and time >= orEndTime
orJustDone  = orComplete and not orComplete[1]

// ─────────────────────────────────────────────
//  OPENING RANGE STATE
// ─────────────────────────────────────────────
var float orHigh = na
var float orLow  = na
var box   orBox  = na
var line  orHiLine  = na
var line  orLoLine  = na
var line  orMidLine = na
var label orHiTag   = na
var label orLoTag   = na
var bool  longFired    = false
var bool  shortFired   = false
var bool  longUnconfFired  = false
var bool  shortUnconfFired = false
var array<line>  tgtLines  = array.new<line>()
var array<label> tgtLabels = array.new<label>()

// Archive of previous sessions' frozen targets, with per-session counts
// so the oldest session's drawings can be pruned FIFO when over the limit.
var array<line>  prevLines     = array.new<line>()
var array<label> prevLabels    = array.new<label>()
var array<int>   prevLineCnts  = array.new<int>()
var array<int>   prevLabelCnts = array.new<int>()

clearTargets() =>
    if tgtKeepPrev
        // Move current session's targets into the archive (frozen in place)
        nLines = array.size(tgtLines)
        nLbls  = array.size(tgtLabels)
        if nLines > 0 or nLbls > 0
            for l in tgtLines
                array.push(prevLines, l)
            for lb in tgtLabels
                array.push(prevLabels, lb)
            array.push(prevLineCnts, nLines)
            array.push(prevLabelCnts, nLbls)
        array.clear(tgtLines)
        array.clear(tgtLabels)
        // Prune oldest sessions beyond the user-set depth
        while array.size(prevLineCnts) > tgtKeepN
            oldL = array.shift(prevLineCnts)
            if oldL > 0
                for i = 1 to oldL
                    line.delete(array.shift(prevLines))
            oldB = array.shift(prevLabelCnts)
            if oldB > 0
                for i = 1 to oldB
                    label.delete(array.shift(prevLabels))
    else
        if array.size(tgtLines) > 0
            for l in tgtLines
                line.delete(l)
            array.clear(tgtLines)
        if array.size(tgtLabels) > 0
            for lb in tgtLabels
                label.delete(lb)
            array.clear(tgtLabels)

if newSession
    orHigh := high
    orLow  := low
    longFired    := false
    shortFired   := false
    longUnconfFired  := false
    shortUnconfFired := false
    clearTargets()
    line.delete(orHiLine)
    line.delete(orLoLine)
    line.delete(orMidLine)
    label.delete(orHiTag)
    label.delete(orLoTag)
    orBox := box.new(left = bar_index, top = high, right = bar_index, bottom = low, bgcolor = colORFill, border_color = colORBorder, border_width = 1)
else if inORWindow
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)
    if not na(orBox)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)
        box.set_right(orBox, bar_index)

// Box extends a fixed number of bars past OR completion, then freezes.
// Levels continue as clean rays — breakouts happen in open space, not inside a block.
var int orDoneBar = na
if orJustDone
    orDoneBar := bar_index
    orHiLine := line.new(bar_index, orHigh, bar_index + 1, orHigh, color = color.new(colBull, 25), width = 2, extend = extend.none)
    orLoLine := line.new(bar_index, orLow,  bar_index + 1, orLow,  color = color.new(colBear, 25), width = 2, extend = extend.none)
    orMidLine := showMidline ? line.new(bar_index, (orHigh + orLow) / 2, bar_index + 1, (orHigh + orLow) / 2, color = color.new(colNeutral, 60), width = 1, style = line.style_dotted) : na
    orHiTag := label.new(bar_index, orHigh, "OR HIGH  " + str.tostring(orHigh, format.mintick), style = label.style_label_left, color = color.new(colBull, 82), textcolor = colBull, size = size.small)
    orLoTag := label.new(bar_index, orLow,  "OR LOW  " + str.tostring(orLow, format.mintick),  style = label.style_label_left, color = color.new(colBear, 82), textcolor = colBear, size = size.small)

// Extend box up to N bars past OR completion, then freeze
if orComplete and inSession and not na(orDoneBar) and not na(orBox)
    box.set_right(orBox, math.min(bar_index, orDoneBar + orExtendBars))

// Extend level rays across the session, keep tags pinned to the right edge
if orComplete and inSession
    line.set_x2(orHiLine, bar_index)
    line.set_x2(orLoLine, bar_index)
    if not na(orMidLine)
        line.set_x2(orMidLine, bar_index)
    label.set_x(orHiTag, bar_index + 2)
    label.set_x(orLoTag, bar_index + 2)

orHeight = orHigh - orLow

// ─────────────────────────────────────────────
//  VOLUME BASELINE / RVOL
//  Time-of-Day mode: per-slot EMA of volume at the same bar-of-session across
//  recent sessions. Correctly handles the U-shaped intraday volume curve —
//  a rolling SMA understates the baseline at the open, inflating RVOL exactly
//  when ORB signals fire. Falls back to rolling SMA until minSessions of
//  history exist for the slot, and always for zero/na cases.
// ─────────────────────────────────────────────
var int barInSession = na
if newSession
    barInSession := 0
else if inSession
    barInSession += 1

var array<float> todBase  = array.new<float>()
var array<int>   todCount = array.new<int>()

// Baseline lookup happens BEFORE updating the slot with the current bar,
// so the current bar never contaminates its own baseline.
float slotBase  = na
int   slotCount = 0
if inSession and not na(barInSession)
    // Grow slot arrays as needed (handles variable session lengths / holidays)
    while array.size(todBase) <= barInSession
        array.push(todBase, na)
        array.push(todCount, 0)
    slotBase  := array.get(todBase, barInSession)
    slotCount := array.get(todCount, barInSession)
    // Update slot with current bar volume (EMA over sessions)
    if volume > 0
        alphaTod = 2.0 / (volLookback + 1)
        newBase = na(slotBase) ? volume : alphaTod * volume + (1 - alphaTod) * slotBase
        array.set(todBase, barInSession, newBase)
        array.set(todCount, barInSession, slotCount + 1)

smaBase = ta.sma(volume, math.min(volLookback, 200))
useTod  = baseMode == "Time-of-Day (adaptive)" and not na(slotBase) and slotCount >= minSessions
volBase = useTod ? slotBase : smaBase

rvol = volBase > 0 and volume > 0 ? volume / volBase : na
rvolOK = not na(rvol) and rvol >= rvolThresh

// Diagnostics: RVOL visible in the Data Window / status line for verification
plot(rvol, "RVOL", color = color.new(color.white, 100), display = display.data_window + display.status_line)

// ─────────────────────────────────────────────
//  BREAKOUT DETECTION
// ─────────────────────────────────────────────
canSignal = orComplete and not na(orHigh) and not na(orLow) and orHeight > 0 and time < orEndTime + int(sigWindowHrs * 3600 * 1000)

crossUp   = canSignal and close > orHigh and close[1] <= orHigh
crossDown = canSignal and close < orLow  and close[1] >= orLow

confLong    = crossUp   and rvolOK and not longFired
confShort   = crossDown and rvolOK and not shortFired
unconfLong  = crossUp   and not rvolOK and not longFired  and not longUnconfFired
unconfShort = crossDown and not rvolOK and not shortFired and not shortUnconfFired

// ─────────────────────────────────────────────
//  TARGETS — thin dashed rays that track price, R-tags on the right
// ─────────────────────────────────────────────
drawTargets(bool isLong) =>
    lvl  = isLong ? orHigh : orLow
    mults = array.from(0.5, 1.0, 1.5, 2.0)
    col  = isLong ? tgtColLong : tgtColShort
    lnStyle = tgtStyleIn == "Solid" ? line.style_solid : tgtStyleIn == "Dotted" ? line.style_dotted : line.style_dashed
    lblSz = tgtLblSize == "Tiny" ? size.tiny : tgtLblSize == "Normal" ? size.normal : size.small
    for m in mults
        tgt = isLong ? lvl + orHeight * m : lvl - orHeight * m
        ln  = line.new(bar_index, tgt, bar_index + 1, tgt, color = color.new(col, tgtTransp), style = lnStyle, width = tgtWidthIn)
        array.push(tgtLines, ln)
        if tgtShowLbl
            lb  = label.new(bar_index + 2, tgt, str.tostring(m, "#.#") + "R  " + str.tostring(tgt, format.mintick), style = label.style_label_left, color = color.new(col, 88), textcolor = col, size = lblSz)
            array.push(tgtLabels, lb)

// Track targets to the right edge every bar
if array.size(tgtLines) > 0 and inSession
    for l in tgtLines
        line.set_x2(l, bar_index)
    for lb in tgtLabels
        label.set_x(lb, bar_index + 2)

// ─────────────────────────────────────────────
//  SIGNAL RENDERING
//  Confirmed = bold pill label OFFSET from price (never inside the box),
//  anchored with a connector line so the trigger bar stays obvious.
// ─────────────────────────────────────────────
atrPad = ta.atr(14)

if confLong
    longFired := true
    yAnchor = low - atrPad * 1.6
    line.new(bar_index, low - atrPad * 0.2, bar_index, yAnchor, color = color.new(colBull, 40), width = 1)
    label.new(bar_index, yAnchor, "▲ LONG BREAK\n" + str.tostring(rvol, "#.#") + "× VOL", style = label.style_label_up, color = colBull, textcolor = color.white, size = size.normal)
    if showTargets
        drawTargets(true)

if confShort
    shortFired := true
    yAnchor = high + atrPad * 1.6
    line.new(bar_index, high + atrPad * 0.2, bar_index, yAnchor, color = color.new(colBear, 40), width = 1)
    label.new(bar_index, yAnchor, "▼ SHORT BREAK\n" + str.tostring(rvol, "#.#") + "× VOL", style = label.style_label_down, color = colBear, textcolor = color.white, size = size.normal)
    if showTargets
        drawTargets(false)

if unconfLong
    longUnconfFired := true
    if showUnconf
        label.new(bar_index, low - atrPad * 0.8, "△ no vol " + str.tostring(rvol, "#.#") + "×", style = label.style_label_up, color = color.new(color.black, 100), textcolor = colNeutral, size = size.small)

if unconfShort
    shortUnconfFired := true
    if showUnconf
        label.new(bar_index, high + atrPad * 0.8, "▽ no vol " + str.tostring(rvol, "#.#") + "×", style = label.style_label_down, color = color.new(color.black, 100), textcolor = colNeutral, size = size.small)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
if confLong and alertConfLong
    alert("ORB+VOL: CONFIRMED LONG breakout on " + syminfo.ticker + " | RVOL " + str.tostring(rvol, "#.##") + "x | OR High " + str.tostring(orHigh, format.mintick), alert.freq_once_per_bar_close)
if confShort and alertConfShort
    alert("ORB+VOL: CONFIRMED SHORT breakout on " + syminfo.ticker + " | RVOL " + str.tostring(rvol, "#.##") + "x | OR Low " + str.tostring(orLow, format.mintick), alert.freq_once_per_bar_close)
if (unconfLong or unconfShort) and alertUnconf
    alert("ORB+VOL: UNCONFIRMED breakout touch on " + syminfo.ticker + " | RVOL " + str.tostring(rvol, "#.##") + "x (below " + str.tostring(rvolThresh, "#.#") + "x threshold)", alert.freq_once_per_bar_close)
````

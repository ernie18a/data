# SwiftEdge Opening Range

- url: https://www.tradingview.com/script/G4tbBavf-SwiftEdge-Opening-Range/
- type: indicator
- pine_id: PUB;75ab5c05fdf946f88ce492c4f42cc7eb
- version: 1.0

## Description

SwiftEdge Opening Range tracks the opening range of up to four fully configurable sessions at once (New York, London, Asia and a custom session by default). It classifies every breakout as held or failed and measures how each session's breakouts have behaved on the chart's history. The goal is to answer, for your own symbol and timeframe, which session's opening range is worth trading, and whether to trade the breakout or the fake-out.

WHAT IT SHOWS

• Opening range per session
The high and low of the first N minutes of each session, drawn as a box while it forms and as a shaded band with high/low lines through the rest of the session. A mid line, optional inner levels (for example 0.25 and 0.75 of the range) and extension levels (multiples of the range, 1× and 2× by default) can be added. Each session has its own name, time window, range length (1 to 480 minutes) and colour, and can be drawn on the chart or only counted in the statistics.

• Breakouts
A breakout is the first bar of the session that closes beyond the range. An optional buffer (in ATR) and an optional relative-volume filter can be required. Breakouts are marked with a small dot in the session's colour.

• Held vs fake-out
After a breakout, the script watches a fake-out window (6 bars by default). If a bar closes back inside the range within that window, the breakout is classed as a fake-out and marked with ×. If not, it is classed as held.

• Breakout playbook (fully configurable)
  – Entry: on the breakout bar's close, with a stop order at the range edge (filled the moment price trades through it), or on a retest of the broken edge within a set number of bars.
  – Stop: opposite side of the range, range mid, ATR multiple, range multiple, or beyond the breakout bar.
  – Targets: target 1 and an optional target 2. Each can be an R multiple, an ATR multiple, a range extension, points, a percentage, or the session end. You choose the share closed at target 1, and the rest runs to target 2.
  – Exit management: break-even after target 1 or at a chosen R, an ATR- or range-based trailing stop (always or only after target 1), a maximum holding time, and an optional exit when the breakout turns into a fake-out.
  – Presets: Classic (close entry, opposite-side stop, 2R), Retest (limit on the broken edge, mid stop, 50% at 1R, rest at 3R), Momentum (stop order, 1 ATR stop, 50% at 1.5 ATR, rest trailed by 1.5 ATR) and Range targets (50% at 1× extension, rest at 2×). Custom uses your own settings.

• Fade playbook
On a fake-out, enter in the opposite direction on the close that confirms it. The stop goes just beyond the breakout extreme or at an ATR distance. The target is the opposite side of the range, the range mid, an R multiple, an ATR multiple, a range extension, points or a percentage.

Commission and slippage are deducted from every trade, and open trades are closed at the session end. Intrabar fills (stop orders, retests, stops and targets) are simulated from each bar's high and low. When a stop and a target could both have been hit in the same bar, the stop is assumed first, and an entry-bar stop is counted as a loss. Trades are drawn like position tools: a risk box and a target box from entry to exit (with a dotted line at target 1 when a partial exit is used) and the result in R next to it.

• Panel (sessions side by side)
  – Today: status (forming, waiting, broke, held, fake-out, in trade) and today's range size in ATR, with its percentile against past sessions.
  – Breakout rate: share of sessions with a breakout, and the up/down split.
  – Held / fake-out: how breakouts resolved.
  – Reached 1× extension: share of breakouts that travelled at least one full range beyond the opening range.
  – Held · narrow / wide range: held rate for sessions whose range was below vs above the median range size. This shows whether small opening ranges break out more cleanly on your market.
  – Breakout trades and fade trades: number of trades, win rate and average result in R, plus how often target 1 was reached. These are repeated for the last part of the history only (out-of-sample, 30% by default) so you can see whether the result is stable.

HOW IT WORKS

1. A session starts on the first bar inside its session window. The range is built from all bars that open within the first N minutes.
2. The range is complete on the first bar that opens after those N minutes. That bar is already checked for a breakout.
3. Breakouts, fake-outs, entries and exits are evaluated only on closed bars, so nothing on the chart changes after a bar closes.
4. Stops and targets are checked against each bar's high and low. If both could have been hit in the same bar, the stop is assumed first. Gaps through a level fill at the open.
5. Range sizes are measured in ATR(14) so sessions and markets can be compared.

HOW TO USE IT

• Pick the sessions you trade and set their times in the timezone input (New York time by default).
• Read the panel before the session: a high breakout rate with a high held rate favours the breakout playbook, while a high fake-out rate favours fading.
• Use today's range percentile together with the narrow/wide row to judge whether today's range is the kind that has tended to hold.
• Compare the full-history and out-of-sample rows. A playbook that only works in the older part of the data is unlikely to be robust.
• Use a chart timeframe at or below the opening-range length (for example 5m for a 30-minute range).

SETTINGS

Sessions (enable, name, time window, range length, colour, draw or statistics only), breakout buffer, relative-volume filter, fake-out window, both playbooks (stops, targets, exit on fake-out, break-even), costs, out-of-sample share, and display options: range box, band, high/low, mid, inner levels, extension levels, level labels (current session, all or off), session title, marks, trades and results, last N sessions or today only, transparencies and colours. The panel position and text size can also be changed.

LIMITATIONS

• Results are simulated on the loaded history and depend on the settings, the data feed and the chart timeframe. They are a measurement, not a forecast, and not a complete trading system.
• Session times are fixed clock times in the chosen timezone. Markets with irregular hours, holidays or half days can produce partial sessions.
• On timeframes longer than the opening range, the range is formed by a single bar and the results become less meaningful.
• Relative volume needs volume data from the feed.

This script is for analysis and education. It does not provide trading advice, and past behaviour shown on the chart does not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  SwiftEdge Opening Range
//  An opening-range lab: up to four configurable sessions, every breakout
//  classified and measured, and a flexible trade engine for the many ways
//  opening ranges are traded.
//
//   • Opening range (OR): high and low of the first N minutes of a session,
//     drawn as a box while it forms and as a band through the session, with
//     a mid line, optional inner levels and extension levels.
//   • Breakout: the first bar of the session that closes beyond the range
//     (optional ATR buffer and relative-volume filter).
//   • Classification: HELD if price stays outside for the fake-out window,
//     FAKE-OUT if a bar closes back inside the range within that window.
//   • Breakout playbook: entry on the close, with a stop order at the range
//     edge, or on a retest of the broken edge. Stops: opposite side, mid,
//     ATR, range multiple or breakout bar. Two targets (R, ATR, range
//     extension, points, percent or session end) with a partial exit,
//     break-even, trailing stop and time exit. Presets for common versions.
//   • Fade playbook: trade against fake-outs with its own stop and target.
//   • Panel: sessions side by side — breakout rate, direction, held vs
//     fake-out, 1× extension rate, held rate for narrow vs wide ranges,
//     target-1 hit rate, both playbooks and an out-of-sample check — plus
//     today's range size as a percentile.
//
//  Everything is decided on bar close; nothing changes after a bar closes.
//  Intrabar fills (stop orders, retests, stops, targets) are simulated from
//  the bar's high and low; when a stop and a target could both have been
//  hit in the same bar, the stop is assumed first.
//  A research and visualization tool. Statistics describe the loaded
//  history only and are not a forecast.
// ═══════════════════════════════════════════════════════════════════════════
indicator("SwiftEdge Opening Range", "SE Opening Range", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpS = "1 · Sessions"
tz   = input.string("America/New_York", "Timezone", group = grpS,
     tooltip = "Session times below are read in this timezone. Each session: enable · name · time window · opening-range length in minutes · colour · draw on chart (statistics are kept either way).")
on1  = input.bool(true, "", inline = "a1", group = grpS)
nm1  = input.string("New York", "", inline = "a1", group = grpS)
ses1 = input.session("0930-1600", "", inline = "a1", group = grpS)
or1  = input.int(30, "OR min", minval = 1, maxval = 480, inline = "b1", group = grpS)
c1   = input.color(#2962ff, "", inline = "b1", group = grpS)
dr1  = input.bool(true, "Draw", inline = "b1", group = grpS)
on2  = input.bool(true, "", inline = "a2", group = grpS)
nm2  = input.string("London", "", inline = "a2", group = grpS)
ses2 = input.session("0300-1130", "", inline = "a2", group = grpS)
or2  = input.int(30, "OR min", minval = 1, maxval = 480, inline = "b2", group = grpS)
c2   = input.color(#ff9800, "", inline = "b2", group = grpS)
dr2  = input.bool(true, "Draw", inline = "b2", group = grpS)
on3  = input.bool(true, "", inline = "a3", group = grpS)
nm3  = input.string("Asia", "", inline = "a3", group = grpS)
ses3 = input.session("2000-0200", "", inline = "a3", group = grpS)
or3  = input.int(30, "OR min", minval = 1, maxval = 480, inline = "b3", group = grpS)
c3   = input.color(#9c27b0, "", inline = "b3", group = grpS)
dr3  = input.bool(true, "Draw", inline = "b3", group = grpS)
on4  = input.bool(false, "", inline = "a4", group = grpS)
nm4  = input.string("Custom", "", inline = "a4", group = grpS)
ses4 = input.session("0800-1200", "", inline = "a4", group = grpS)
or4  = input.int(15, "OR min", minval = 1, maxval = 480, inline = "b4", group = grpS)
c4   = input.color(#00897b, "", inline = "b4", group = grpS)
dr4  = input.bool(true, "Draw", inline = "b4", group = grpS)

grpB = "2 · Breakout definition"
bufAtr   = input.float(0.0, "Buffer beyond the range (× ATR14)", minval = 0.0, maxval = 2.0, step = 0.05, group = grpB)
rvolMin  = input.float(0.0, "Min relative volume on the breakout bar (0 = off)", minval = 0.0, maxval = 10, step = 0.1, group = grpB)
fakeBars = input.int(6, "Fake-out window (bars after the breakout)", minval = 1, maxval = 100, group = grpB,
     tooltip = "A breakout is a fake-out when a bar closes back inside the range within this many bars. Otherwise it is classed as held.")

grpP = "3 · Breakout playbook"
useBO     = input.bool(true, "Trade the breakout", group = grpP)
preset    = input.string("Custom", "Preset", options = ["Custom", "Classic", "Retest", "Momentum", "Range targets"], group = grpP,
     tooltip = "Classic: close entry, opposite-side stop, 2R.\nRetest: limit on the broken edge, mid stop, 50% at 1R, rest at 3R, break-even after target 1.\nMomentum: stop order at the edge, 1 ATR stop, 50% at 1.5 ATR, rest trails 1.5 ATR.\nRange targets: close entry, mid stop, 50% at 1× range extension, rest at 2×.\nCustom: uses the settings below.")
entryMode = input.string("Bar close", "Entry", options = ["Bar close", "Stop order at range edge", "Retest of the edge"], group = grpP)
retBars   = input.int(10, "Retest window (bars after the breakout)", minval = 1, maxval = 200, group = grpP)
stopT     = input.string("Opposite side", "Stop", options = ["Opposite side", "Range mid", "ATR ×", "Range ×", "Breakout bar"], inline = "st", group = grpP)
stopV     = input.float(1.0, "", minval = 0.05, step = 0.05, inline = "st", group = grpP)
tp1T      = input.string("R multiple", "Target 1", options = ["R multiple", "ATR ×", "Range ext.", "Points", "Percent", "Session end"], inline = "t1", group = grpP)
tp1V      = input.float(2.0, "", minval = 0.0, step = 0.25, inline = "t1", group = grpP)
tp1Pct    = input.float(100, "% closed at target 1", minval = 1, maxval = 100, step = 5, group = grpP)
tp2T      = input.string("None", "Target 2", options = ["None", "R multiple", "ATR ×", "Range ext.", "Points", "Percent"], inline = "t2", group = grpP,
     tooltip = "For the part left open after target 1. None = it runs until the stop, trailing stop, time exit or session end.")
tp2V      = input.float(3.0, "", minval = 0.0, step = 0.25, inline = "t2", group = grpP)
exitFake  = input.bool(true, "Exit on a fake-out", group = grpP)

grpF = "4 · Fade playbook"
useFade  = input.bool(true, "Fade fake-outs", group = grpF)
fdStopT  = input.string("Breakout extreme", "Stop", options = ["Breakout extreme", "ATR ×"], inline = "fs", group = grpF,
     tooltip = "Breakout extreme: just beyond the furthest point of the failed breakout (value = buffer in ATR). ATR ×: a fixed ATR distance from entry.")
fdStopV  = input.float(0.1, "", minval = 0.0, step = 0.05, inline = "fs", group = grpF)
fdTgtT   = input.string("Opposite side", "Target", options = ["Opposite side", "Range mid", "R multiple", "ATR ×", "Range ext.", "Points", "Percent"], inline = "ft", group = grpF)
fdTgtV   = input.float(2.0, "", minval = 0.0, step = 0.25, inline = "ft", group = grpF)

grpX = "5 · Exit management (both playbooks)"
beTp1     = input.bool(true, "Stop to break-even after target 1", group = grpX)
beAtR     = input.float(0.0, "Stop to break-even at R (0 = off)", minval = 0.0, step = 0.25, group = grpX)
trailT    = input.string("None", "Trailing stop", options = ["None", "ATR ×", "Range ×"], inline = "tr", group = grpX)
trailV    = input.float(1.5, "", minval = 0.1, step = 0.1, inline = "tr", group = grpX)
trailTp1  = input.bool(true, "Trail only after target 1", group = grpX)
maxHold   = input.int(0, "Max hold (bars, 0 = off)", minval = 0, group = grpX)
commPct   = input.float(0.01, "Commission per side (%)", minval = 0.0, step = 0.005, group = grpX)
slipTk    = input.int(1, "Slippage per fill (ticks)", minval = 0, group = grpX)
oosPct    = input.float(30, "Out-of-sample = last % of history", minval = 0, maxval = 90, group = grpX)

grpV = "6 · Style"
viewMode   = input.string("Last N sessions", "Show", options = ["Last N sessions", "Today only"], inline = "vm", group = grpV)
keepDays   = input.int(5, "N", minval = 1, maxval = 60, inline = "vm", group = grpV)
showForm   = input.bool(true, "Range box", inline = "v1", group = grpV)
showBand   = input.bool(true, "Range band", inline = "v1", group = grpV)
showLines  = input.bool(true, "High / low", inline = "v1", group = grpV)
showMid    = input.bool(true, "Mid", inline = "v1", group = grpV)
innerStr   = input.string("", "Inner levels (fraction of range)", group = grpV, tooltip = "Comma-separated, e.g. 0.25, 0.75. Leave empty for none.")
extStr     = input.string("1, 2", "Extension levels (× range)", group = grpV, tooltip = "Comma-separated multiples of the range, drawn above and below. Leave empty for none.")
extLblMode = input.string("Current session", "Level labels", options = ["Current session", "All", "Off"], group = grpV)
showTitle  = input.bool(true, "Session title", inline = "v2", group = grpV)
showMarks  = input.bool(true, "Breakout / fake-out marks", inline = "v2", group = grpV)
showTrades = input.bool(true, "Trades (position boxes)", inline = "v3", group = grpV)
showRes    = input.bool(true, "Trade result", inline = "v3", group = grpV)
formTr     = input.int(82, "Box transparency", minval = 0, maxval = 100, inline = "tr2", group = grpV)
bandTr     = input.int(94, "Band", minval = 0, maxval = 100, inline = "tr2", group = grpV)
cUp        = input.color(#089981, "Profit", inline = "c", group = grpV)
cDn        = input.color(#f23645, "Risk", inline = "c", group = grpV)

grpD = "7 · Panel"
showPanel = input.bool(true, "Show panel", inline = "p0", group = grpD)
panelPos  = input.string("Bottom right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "p0", group = grpD)
panelSz   = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal"], group = grpD)

// ═══ Effective breakout settings (preset or custom) ═════════════════════════
pEntry  = preset == "Classic" ? "Bar close" : preset == "Retest" ? "Retest of the edge" : preset == "Momentum" ? "Stop order at range edge" : preset == "Range targets" ? "Bar close" : entryMode
pStopT  = preset == "Classic" ? "Opposite side" : preset == "Retest" ? "Range mid" : preset == "Momentum" ? "ATR ×" : preset == "Range targets" ? "Range mid" : stopT
pStopV  = preset == "Custom" ? stopV : 1.0
pTp1T   = preset == "Classic" ? "R multiple" : preset == "Retest" ? "R multiple" : preset == "Momentum" ? "ATR ×" : preset == "Range targets" ? "Range ext." : tp1T
pTp1V   = preset == "Classic" ? 2.0 : preset == "Retest" ? 1.0 : preset == "Momentum" ? 1.5 : preset == "Range targets" ? 1.0 : tp1V
pTp1Pct = preset == "Classic" ? 100.0 : preset == "Custom" ? tp1Pct : 50.0
pTp2T   = preset == "Classic" ? "None" : preset == "Retest" ? "R multiple" : preset == "Momentum" ? "None" : preset == "Range targets" ? "Range ext." : tp2T
pTp2V   = preset == "Retest" ? 3.0 : preset == "Range targets" ? 2.0 : tp2V
pBeTp1  = preset == "Custom" ? beTp1 : preset != "Classic"
pTrailT = preset == "Momentum" ? "ATR ×" : preset == "Custom" ? trailT : "None"
pTrailV = preset == "Momentum" ? 1.5 : trailV

// ═══ Helpers ═══════════════════════════════════════════════════════════════
cTxt  = #d1d4dc
cMute = #787b86
atr    = ta.atr(14)
volAvg = ta.sma(volume, 20)
slip   = slipTk * syminfo.mintick
keepN  = viewMode == "Today only" ? 1 : keepDays

sizeOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

pctS(float x) =>
    na(x) ? "—" : str.tostring(x, "#") + "%"

f2(float x) =>
    na(x) ? "—" : str.tostring(x, "#.##")

parseList(string src) =>
    out = array.new_float()
    if str.length(str.trim(src)) > 0
        for p in str.split(src, ",")
            v = str.tonumber(str.trim(p))
            if not na(v) and v > 0
                out.push(v)
    out

// a target price for direction d, or na when it is not beyond the entry
targetPx(string t, float v, int d, float e, float rk, float hi, float lo, float rng) =>
    float px = na
    if t == "R multiple"
        px := e + d * v * rk
    else if t == "ATR ×"
        px := e + d * v * atr
    else if t == "Range ext."
        px := d == 1 ? hi + v * rng : lo - v * rng
    else if t == "Points"
        px := e + d * v
    else if t == "Percent"
        px := e * (1 + d * v / 100)
    else if t == "Opposite side"
        px := d == 1 ? hi : lo
    else if t == "Range mid"
        px := (hi + lo) / 2
    na(px) or (d == 1 ? px <= e : px >= e) ? float(na) : px

shortT(string t, float v) =>
    t == "R multiple" ? str.tostring(v) + "R" : t == "ATR ×" ? str.tostring(v) + " ATR" : t == "Range ext." ? str.tostring(v) + "× ext" :
     t == "Points" ? str.tostring(v) + " pts" : t == "Percent" ? str.tostring(v) + "%" : t == "Session end" ? "session end" : t

var extLv   = parseList(extStr)
var innerLv = parseList(innerStr)

// ═══ Session object ════════════════════════════════════════════════════════
type Sess
    string name
    string ses
    int orMin
    color col
    bool on
    bool drw
    bool wasIn = false
    int t0 = na
    int x0 = na
    float hi = na
    float lo = na
    bool forming = false
    bool done = false
    float rng = na
    int brkDir = 0
    int brkBar = na
    float brkExt = na
    bool failed = false
    bool boTaken = false
    bool fdTaken = false
    int retDir = 0
    int retUntil = na
    box formBx = na
    box bandBx = na
    label ttl = na
    array<line> dayLn
    array<label> lvlLb
    array<float> dRng          // range size in ATR, one per session day
    array<int> dBrk            // 0 none, 1 up, -1 down
    array<int> dOut            // 0 pending, 1 held, 2 fake-out
    array<float> dExt          // furthest extension reached, in range multiples
    array<float> trR           // trade results in R
    array<int> trT
    array<int> trK             // 0 breakout, 1 fade
    array<bool> trTp1          // target 1 reached
    int pos = 0
    int pKind = 0
    float ePx = na
    float stp = na
    float tp1 = na
    float tp2 = na
    float frac1 = 1.0
    float rk = na
    int eBar = na
    bool tp1Done = false
    bool beDone = false
    float realR = 0.0
    float rem = 1.0
    box tBx = na
    box sBx = na
    line tp1Ln = na
    array<box> qB
    array<line> qL
    array<label> qLb

newSess(string nm, string ses, int om, color c, bool on, bool drw) =>
    Sess.new(nm, ses, om, c, on, drw, dayLn = array.new_line(), lvlLb = array.new_label(), dRng = array.new_float(),
         dBrk = array.new_int(), dOut = array.new_int(), dExt = array.new_float(), trR = array.new_float(), trT = array.new_int(),
         trK = array.new_int(), trTp1 = array.new_bool(), qB = array.new_box(), qL = array.new_line(), qLb = array.new_label())

var sessions = array.from(newSess(nm1, ses1, or1, c1, on1, dr1), newSess(nm2, ses2, or2, c2, on2, dr2),
     newSess(nm3, ses3, or3, c3, on3, dr3), newSess(nm4, ses4, or4, c4, on4, dr4))

perDay = 10 + 2 * array.size(extLv) + array.size(innerLv)

method keepB(Sess s, box b) =>
    if not na(b)
        s.qB.push(b)
        if s.qB.size() > keepN * 6
            old = s.qB.shift()
            if not na(old)
                box.delete(old)
    true

method keepL(Sess s, line l) =>
    if not na(l)
        s.qL.push(l)
        if s.qL.size() > keepN * perDay
            old = s.qL.shift()
            if not na(old)
                line.delete(old)
    true

method keepLb(Sess s, label l) =>
    if not na(l)
        s.qLb.push(l)
        if s.qLb.size() > keepN * perDay
            old = s.qLb.shift()
            if not na(old)
                label.delete(old)
    true

method startDay(Sess s) =>
    s.t0 := time
    s.x0 := bar_index
    s.hi := high
    s.lo := low
    s.forming := true
    s.done := false
    s.rng := na
    s.brkDir := 0
    s.brkBar := na
    s.brkExt := na
    s.failed := false
    s.boTaken := false
    s.fdTaken := false
    s.retDir := 0
    s.dayLn.clear()
    if extLblMode == "Current session"
        for lb in s.lvlLb
            label.delete(lb)
    s.lvlLb.clear()
    s.formBx := na
    s.bandBx := na
    s.ttl := na
    if s.drw and showForm
        s.formBx := box.new(bar_index, high, bar_index + 1, low, border_color = color.new(s.col, 45), bgcolor = color.new(s.col, formTr))
        s.keepB(s.formBx)
    if s.drw and showTitle
        s.ttl := label.new(bar_index, high, s.name + " · " + str.tostring(s.orMin) + "m", style = label.style_label_lower_left,
             color = color.new(color.black, 100), textcolor = color.new(s.col, 25), size = size.tiny)
        s.keepLb(s.ttl)
    true

method levelLine(Sess s, float y, color c, string st, string txt) =>
    ln = line.new(bar_index, y, bar_index, y, color = c, style = st, width = 1)
    s.dayLn.push(ln)
    s.keepL(ln)
    if extLblMode != "Off" and txt != ""
        lb = label.new(bar_index, y, txt, style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = color.new(s.col, 35), size = size.tiny)
        s.lvlLb.push(lb)
        if extLblMode == "All"
            s.keepLb(lb)
    true

method completeOR(Sess s) =>
    s.forming := false
    s.done := true
    s.rng := s.hi - s.lo
    if s.drw
        if showBand
            s.bandBx := box.new(bar_index, s.hi, bar_index, s.lo, border_color = color(na), bgcolor = color.new(s.col, bandTr))
            s.keepB(s.bandBx)
        if showLines
            s.levelLine(s.hi, color.new(s.col, 10), line.style_solid, "")
            s.levelLine(s.lo, color.new(s.col, 10), line.style_solid, "")
        if showMid
            s.levelLine((s.hi + s.lo) / 2, color.new(s.col, 50), line.style_dotted, "")
        if s.rng > 0
            for f in innerLv
                if f < 1
                    s.levelLine(s.lo + f * s.rng, color.new(s.col, 70), line.style_dotted, str.tostring(f))
            for lv in extLv
                s.levelLine(s.hi + lv * s.rng, color.new(s.col, 60), line.style_dashed, "+" + str.tostring(lv) + "×")
                s.levelLine(s.lo - lv * s.rng, color.new(s.col, 60), line.style_dashed, "−" + str.tostring(lv) + "×")
    s.dRng.push(atr > 0 ? s.rng / atr : na)
    s.dBrk.push(0)
    s.dOut.push(0)
    s.dExt.push(0.0)
    true

method extend(Sess s) =>
    for ln in s.dayLn
        line.set_x2(ln, bar_index)
    for lb in s.lvlLb
        label.set_x(lb, bar_index)
    if not na(s.bandBx)
        box.set_right(s.bandBx, bar_index)
    true

method closeT(Sess s, float x, string why) =>
    cost = 2 * commPct / 100 * s.ePx + 2 * slip
    r = s.rk > 0 ? s.realR + s.rem * s.pos * (x - s.ePx) / s.rk - cost / s.rk : 0.0
    s.trR.push(r)
    s.trT.push(time)
    s.trK.push(s.pKind)
    s.trTp1.push(s.tp1Done)
    if not na(s.sBx)
        box.set_right(s.sBx, bar_index)
    if not na(s.tBx)
        box.set_right(s.tBx, bar_index)
    if not na(s.tp1Ln)
        line.set_x2(s.tp1Ln, bar_index)
    if s.drw and showTrades and showRes
        s.keepLb(label.new(bar_index, x, (r >= 0 ? "+" : "") + str.tostring(r, "#.#") + "R", style = label.style_label_left,
             color = color.new(color.black, 100), textcolor = r > 0 ? cUp : cDn, size = size.tiny,
             tooltip = s.name + (s.pKind == 0 ? " · breakout " : " · fade ") + (s.pos == 1 ? "long" : "short") +
             "\nEntry " + str.tostring(s.ePx, format.mintick) + "  ·  exit " + str.tostring(x, format.mintick) + " (" + why + ")" +
             (s.tp1Done ? "\nTarget 1 reached" : "")))
    s.pos := 0
    s.beDone := false
    true

// open a position; intrabar fills check the stop on the same bar (conservative)
method openT(Sess s, int d, int kind, float e, float st, float t1, float t2, float f1, bool intrabar) =>
    s.pos := d
    s.pKind := kind
    s.ePx := e
    s.stp := st
    s.tp1 := t1
    s.tp2 := na(t1) ? float(na) : t2
    s.frac1 := na(t1) ? 1.0 : f1
    s.rk := math.abs(e - st)
    s.eBar := bar_index
    s.tp1Done := false
    s.beDone := false
    s.realR := 0.0
    s.rem := 1.0
    s.tBx := na
    s.sBx := na
    s.tp1Ln := na
    if s.drw and showTrades
        s.sBx := box.new(bar_index, math.max(e, st), bar_index + 1, math.min(e, st), border_color = color(na), bgcolor = color.new(cDn, 85),
             text = kind == 0 ? "" : "fade", text_size = size.tiny, text_color = color.new(cDn, 20), text_halign = text.align_left)
        s.keepB(s.sBx)
        fin = not na(s.tp2) and s.frac1 < 1 ? s.tp2 : t1
        if not na(fin)
            s.tBx := box.new(bar_index, math.max(e, fin), bar_index + 1, math.min(e, fin), border_color = color(na), bgcolor = color.new(cUp, 85))
            s.keepB(s.tBx)
            if not na(s.tp2) and s.frac1 < 1
                s.tp1Ln := line.new(bar_index, t1, bar_index + 1, t1, color = color.new(cUp, 30), style = line.style_dotted)
                s.keepL(s.tp1Ln)
    if intrabar and (d == 1 ? low <= st : high >= st)
        s.closeT(st - d * slip, "stop (entry bar)")
    true

method manage(Sess s) =>
    if s.pos != 0 and bar_index > s.eBar
        d = s.pos
        if not na(s.sBx)
            box.set_right(s.sBx, bar_index)
        if not na(s.tBx)
            box.set_right(s.tBx, bar_index)
        if not na(s.tp1Ln)
            line.set_x2(s.tp1Ln, bar_index)
        gapS = d == 1 ? open <= s.stp : open >= s.stp
        hitS = d == 1 ? low <= s.stp : high >= s.stp
        sWhy = s.beDone ? "break-even" : s.tp1Done ? "stop after target 1" : "stop"
        if gapS
            s.closeT(open - d * slip, sWhy + " (gap)")
        else if hitS
            s.closeT(s.stp - d * slip, sWhy)
        else
            // target 1 (full exit, or partial)
            if not s.tp1Done and not na(s.tp1) and (d == 1 ? high >= s.tp1 : low <= s.tp1)
                f1 = d == 1 ? math.max(open, s.tp1) : math.min(open, s.tp1)
                s.tp1Done := true
                if s.frac1 >= 1
                    s.closeT(f1 - d * slip, "target")
                else
                    s.realR += s.frac1 * d * (f1 - s.ePx) / s.rk
                    s.rem := 1 - s.frac1
                    if pBeTp1
                        s.stp := d == 1 ? math.max(s.stp, s.ePx) : math.min(s.stp, s.ePx)
                        s.beDone := true
            // target 2 (same bar allowed once target 1 is done)
            if s.pos != 0 and s.tp1Done and not na(s.tp2) and (d == 1 ? high >= s.tp2 : low <= s.tp2)
                s.closeT(s.tp2 - d * slip, "target 2")
            if s.pos != 0
                if beAtR > 0 and not s.beDone and d * (close - s.ePx) >= beAtR * s.rk
                    s.stp := d == 1 ? math.max(s.stp, s.ePx) : math.min(s.stp, s.ePx)
                    s.beDone := true
                if pTrailT != "None" and (not trailTp1 or s.tp1Done)
                    dist = pTrailT == "ATR ×" ? pTrailV * atr : pTrailV * s.rng
                    tr = close - d * dist
                    s.stp := d == 1 ? math.max(s.stp, tr) : math.min(s.stp, tr)
                if maxHold > 0 and bar_index - s.eBar >= maxHold
                    s.closeT(close - d * slip, "time exit")
    true

method finishDay(Sess s) =>
    if s.pos != 0
        s.closeT(open - s.pos * slip, "session end")
    if s.done and s.brkDir != 0 and s.dOut.size() > 0 and s.dOut.last() == 0
        s.dOut.set(s.dOut.size() - 1, 1)
    s.forming := false
    s.done := false
    s.retDir := 0
    true

// breakout entry with the effective (preset or custom) settings
method enterBreakout(Sess s, int d, float e, bool intrabar) =>
    st = pStopT == "Opposite side" ? (d == 1 ? s.lo : s.hi) : pStopT == "Range mid" ? (s.hi + s.lo) / 2 :
         pStopT == "ATR ×" ? e - d * pStopV * atr : pStopT == "Range ×" ? e - d * pStopV * s.rng : (d == 1 ? low : high) - d * syminfo.mintick
    rk = math.abs(e - st)
    if rk > 0 and (d == 1 ? st < e : st > e)
        t1 = pTp1T == "Session end" ? float(na) : targetPx(pTp1T, pTp1V, d, e, rk, s.hi, s.lo, s.rng)
        t2 = pTp2T == "None" ? float(na) : targetPx(pTp2T, pTp2V, d, e, rk, s.hi, s.lo, s.rng)
        t2 := not na(t1) and not na(t2) and (d == 1 ? t2 <= t1 : t2 >= t1) ? float(na) : t2
        s.openT(d, 0, e, st, t1, t2, pTp1Pct / 100, intrabar)
        s.boTaken := true
    true

// ═══ Engine (decided on bar close) ═════════════════════════════════════════
bool evOR    = false
bool evUp    = false
bool evDn    = false
bool evFake  = false
bool evEntry = false
var int firstT = na
if na(firstT)
    firstT := time

if barstate.isconfirmed
    for s in sessions
        if s.on
            inS = not na(time(timeframe.period, s.ses, tz))
            if s.wasIn and not inS
                s.finishDay()
            if inS and not s.wasIn
                s.startDay()
            else if inS and s.forming and time < s.t0 + s.orMin * 60000
                s.hi := math.max(s.hi, high)
                s.lo := math.min(s.lo, low)
                if not na(s.formBx)
                    box.set_top(s.formBx, s.hi)
                    box.set_bottom(s.formBx, s.lo)
                    box.set_right(s.formBx, bar_index + 1)
                if not na(s.ttl)
                    label.set_y(s.ttl, s.hi)
            if inS and s.forming and time >= s.t0 + s.orMin * 60000
                s.completeOR()
                evOR := true
            if inS and s.done and s.rng > 0
                s.extend()
                s.manage()
                last = s.dBrk.size() - 1
                bufV = bufAtr * atr
                // stop-order entry at the range edge (before the close-based classification)
                if useBO and pEntry == "Stop order at range edge" and s.pos == 0 and not s.boTaken and s.brkDir == 0
                    upT = high >= s.hi + bufV
                    dnT = low <= s.lo - bufV
                    if upT != dnT
                        d = upT ? 1 : -1
                        lvl = d == 1 ? s.hi + bufV : s.lo - bufV
                        e = (d == 1 ? math.max(open, lvl) : math.min(open, lvl)) + d * slip
                        s.enterBreakout(d, e, true)
                        evEntry := true
                // retest entry: limit on the broken edge
                if useBO and pEntry == "Retest of the edge" and s.retDir != 0 and s.pos == 0 and not s.boTaken and bar_index > s.brkBar
                    if bar_index > s.retUntil
                        s.retDir := 0
                    else
                        d = s.retDir
                        edge = d == 1 ? s.hi : s.lo
                        if d == 1 ? low <= edge : high >= edge
                            e = (d == 1 ? math.min(open, edge) : math.max(open, edge)) + d * slip
                            s.enterBreakout(d, e, true)
                            s.retDir := 0
                            evEntry := true
                if s.brkDir == 0
                    rvOK = rvolMin <= 0 or (volAvg > 0 and volume / volAvg >= rvolMin)
                    up   = rvOK and close > s.hi + bufV
                    dn   = rvOK and close < s.lo - bufV
                    if up or dn
                        d = up ? 1 : -1
                        s.brkDir := d
                        s.brkBar := bar_index
                        s.brkExt := d == 1 ? high : low
                        s.dBrk.set(last, d)
                        s.dExt.set(last, (d == 1 ? high - s.hi : s.lo - low) / s.rng)
                        evUp := d == 1
                        evDn := d == -1
                        if s.drw and showMarks
                            s.keepLb(label.new(bar_index, close, "", style = label.style_circle, color = color.new(s.col, 0), size = size.tiny,
                                 tooltip = s.name + " breakout " + (d == 1 ? "up" : "down") + "\nRange " + str.tostring(s.rng / atr, "#.##") + " ATR"))
                        if useBO and s.pos == 0 and not s.boTaken
                            if pEntry == "Bar close"
                                s.enterBreakout(d, close + d * slip, false)
                                evEntry := true
                            else if pEntry == "Retest of the edge"
                                s.retDir := d
                                s.retUntil := bar_index + retBars
                else
                    d = s.brkDir
                    if not s.failed
                        s.brkExt := d == 1 ? math.max(s.brkExt, high) : math.min(s.brkExt, low)
                    s.dExt.set(last, math.max(s.dExt.get(last), (d == 1 ? high - s.hi : s.lo - low) / s.rng))
                    if s.dOut.get(last) == 0
                        inside = d == 1 ? close < s.hi : close > s.lo
                        if inside and bar_index - s.brkBar <= fakeBars
                            s.failed := true
                            s.dOut.set(last, 2)
                            s.retDir := 0
                            evFake := true
                            if s.drw and showMarks
                                s.keepLb(label.new(bar_index, s.brkExt, "×", style = d == 1 ? label.style_label_down : label.style_label_up,
                                     color = color.new(color.black, 100), textcolor = color.new(s.col, 10), size = size.tiny,
                                     tooltip = s.name + " fake-out: closed back inside the range " + str.tostring(bar_index - s.brkBar) + " bar(s) after the breakout"))
                            if exitFake and s.pos == d and s.pKind == 0
                                s.closeT(close - d * slip, "fake-out")
                            if useFade and s.pos == 0 and not s.fdTaken
                                fd = -d
                                e  = close + fd * slip
                                st = fdStopT == "Breakout extreme" ? (d == 1 ? s.brkExt + fdStopV * atr : s.brkExt - fdStopV * atr) : e - fd * fdStopV * atr
                                rk = math.abs(e - st)
                                tg = targetPx(fdTgtT, fdTgtV, fd, e, rk, s.hi, s.lo, s.rng)
                                if rk > 0 and (fd == 1 ? st < e : st > e) and not na(tg)
                                    s.openT(fd, 1, e, st, tg, float(na), 1.0, false)
                                    s.fdTaken := true
                                    evEntry := true
                        else if bar_index - s.brkBar > fakeBars
                            s.dOut.set(last, 1)
            s.wasIn := inS

// ═══ Statistics ════════════════════════════════════════════════════════════
tradeStats(Sess s, int kind, int spT, bool oosOnly) =>
    int n = 0
    int w = 0
    int t1 = 0
    float sm = 0.0
    if s.trR.size() > 0
        for i = 0 to s.trR.size() - 1
            if s.trK.get(i) == kind and (not oosOnly or s.trT.get(i) >= spT)
                r = s.trR.get(i)
                n += 1
                sm += r
                w += r > 0 ? 1 : 0
                t1 += s.trTp1.get(i) ? 1 : 0
    [n, n > 0 ? w * 100.0 / n : na, n > 0 ? sm / n : na, n > 0 ? t1 * 100.0 / n : na]

dayStats(Sess s) =>
    int days = s.dRng.size()
    int nB = 0
    int nU = 0
    int nH = 0
    int nF = 0
    int nE = 0
    int nHN = 0
    int nRN = 0
    int nHW = 0
    int nRW = 0
    float med = na
    if days > 0
        srt = s.dRng.copy()
        srt.sort()
        med := srt.get(int(days / 2))
        for i = 0 to days - 1
            b = s.dBrk.get(i)
            o = s.dOut.get(i)
            if b != 0
                nB += 1
                nU += b == 1 ? 1 : 0
                nE += s.dExt.get(i) >= 1 ? 1 : 0
                if o != 0
                    nH += o == 1 ? 1 : 0
                    nF += o == 2 ? 1 : 0
                    if s.dRng.get(i) <= med
                        nRN += 1
                        nHN += o == 1 ? 1 : 0
                    else
                        nRW += 1
                        nHW += o == 1 ? 1 : 0
    nRes = nH + nF
    [days, days > 0 ? nB * 100.0 / days : na, nB > 0 ? nU * 100.0 / nB : na,
     nRes > 0 ? nH * 100.0 / nRes : na, nRes > 0 ? nF * 100.0 / nRes : na, nB > 0 ? nE * 100.0 / nB : na,
     nRN > 0 ? nHN * 100.0 / nRN : na, nRW > 0 ? nHW * 100.0 / nRW : na]

statusOf(Sess s) =>
    string st = "closed"
    if s.forming
        st := "forming"
    else if s.done and s.brkDir == 0
        st := "waiting"
    else if s.done and s.dOut.size() > 0
        o = s.dOut.last()
        st := o == 2 ? "fake-out " + (s.brkDir == 1 ? "▲" : "▼") : o == 1 ? "held " + (s.brkDir == 1 ? "▲" : "▼") : "broke " + (s.brkDir == 1 ? "▲" : "▼")
    st + (s.pos != 0 ? " · in trade" : s.retDir != 0 ? " · retest armed" : "")

tradeTxt(int n, float wr, float ex) =>
    n == 0 ? "—" : str.tostring(n) + " · " + str.tostring(wr, "#") + "% · " + (ex >= 0 ? "+" : "") + str.tostring(ex, "#.##")

entryShort = pEntry == "Bar close" ? "close" : pEntry == "Stop order at range edge" ? "stop order" : "retest"
setupTxt = (preset == "Custom" ? "" : preset + ": ") + entryShort + " · stop " + (pStopT == "ATR ×" or pStopT == "Range ×" ? str.tostring(pStopV) + " " + pStopT : str.lower(pStopT)) +
     " · T1 " + shortT(pTp1T, pTp1V) + (pTp1Pct < 100 ? " (" + str.tostring(pTp1Pct, "#") + "%)" : "") +
     (pTp2T != "None" and pTp1Pct < 100 ? " · T2 " + shortT(pTp2T, pTp2V) : "") + (pTrailT != "None" ? " · trail " + str.tostring(pTrailV) + " " + pTrailT : "")

// ═══ Panel ═════════════════════════════════════════════════════════════════
var table panel = na
if showPanel and barstate.islast
    PS = sizeOf(panelSz)
    act = array.new_int()
    for i = 0 to 3
        if sessions.get(i).on
            act.push(i)
    if not na(panel)
        table.delete(panel)
    panel := table.new(posOf(panelPos), act.size() + 1, 19, bgcolor = color.new(#131722, 8), frame_color = #2a2e39, frame_width = 1, border_width = 0)
    spT = firstT + int((time - firstT) * (1 - oosPct / 100))
    rows = array.from("SwiftEdge Opening Range", "Today", "Today's range", "", "Sessions", "Breakout rate", "Up / down",
         "Held / fake-out", "Reached 1× extension", "Held · narrow / wide range", "", "Breakout trades", "Target 1 hit",
         "Fade trades", "Breakout · out-of-sample", "Fade · out-of-sample", "", "trades · win% · avg R", "Setup: " + setupTxt)
    for r = 0 to rows.size() - 1
        table.cell(panel, 0, r, rows.get(r), text_color = r == 0 ? cTxt : r >= 17 ? color.new(cMute, 30) : cMute, text_size = PS, text_halign = text.align_left)
    if act.size() > 0
        for c = 0 to act.size() - 1
            s = sessions.get(act.get(c))
            col = c + 1
            [days, brkP, upP, heldP, fakeP, extP, hN, hW] = dayStats(s)
            [bN, bWR, bEx, bT1] = tradeStats(s, 0, spT, false)
            [fN, fWR, fEx, fT1] = tradeStats(s, 1, spT, false)
            [boN, boWR, boEx, boT1] = tradeStats(s, 0, spT, true)
            [foN, foWR, foEx, foT1] = tradeStats(s, 1, spT, true)
            string today = "—"
            if s.dRng.size() > 0 and not s.forming
                cur = s.dRng.last()
                int below = 0
                for v in s.dRng
                    below += v < cur ? 1 : 0
                pc = s.dRng.size() > 4 ? below * 100.0 / s.dRng.size() : na
                today := f2(cur) + " ATR" + (na(pc) ? "" : " · " + str.tostring(pc, "#") + " pct")
            table.cell(panel, col, 0, s.name + " · " + str.tostring(s.orMin) + "m", text_color = s.col, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 1, statusOf(s), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 2, today, text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 4, str.tostring(days), text_color = days < 50 ? #ffb74d : cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 5, pctS(brkP), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 6, na(upP) ? "—" : str.tostring(upP, "#") + " / " + str.tostring(100 - upP, "#"), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 7, na(heldP) ? "—" : str.tostring(heldP, "#") + " / " + str.tostring(fakeP, "#") + "%", text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 8, pctS(extP), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 9, pctS(hN) + " / " + pctS(hW), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 11, tradeTxt(bN, bWR, bEx), text_color = bN == 0 ? cMute : bEx > 0 ? cUp : cDn, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 12, pctS(bT1), text_color = cTxt, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 13, tradeTxt(fN, fWR, fEx), text_color = fN == 0 ? cMute : fEx > 0 ? cUp : cDn, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 14, tradeTxt(boN, boWR, boEx), text_color = boN == 0 ? cMute : boEx > 0 ? cUp : cDn, text_size = PS, text_halign = text.align_right)
            table.cell(panel, col, 15, tradeTxt(foN, foWR, foEx), text_color = foN == 0 ? cMute : foEx > 0 ? cUp : cDn, text_size = PS, text_halign = text.align_right)

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(evOR, "Opening range complete", "SE Opening Range: an opening range is complete")
alertcondition(evUp, "Breakout up", "SE Opening Range: breakout up")
alertcondition(evDn, "Breakout down", "SE Opening Range: breakout down")
alertcondition(evFake, "Fake-out", "SE Opening Range: fake-out (closed back inside the range)")
alertcondition(evEntry, "Trade entry", "SE Opening Range: playbook entry")
````

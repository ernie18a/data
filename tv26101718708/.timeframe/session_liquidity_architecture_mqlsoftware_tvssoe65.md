# Session Liquidity Architecture [MQLSoftware]

- url: https://www.tradingview.com/script/TVsSOe65-Session-Liquidity-Architecture-MQLSoftware/
- type: indicator
- pine_id: PUB;bbd9ebd39f384a6897162b0bbdc37287
- version: 1.0

## Description

Session Liquidity Architecture reads the trading day as a repeating structure of sessions — and instead of restating fixed session folklore, it [b]measures[/b] how the instrument on your chart actually behaves inside that structure.

Most session tools draw boxes and stop there. This indicator adds three algorithmic elements on top of the session-box base, and every number it prints is derived from the chart's own history.

[b]Key Features[/b]
[list]
[*][b]Self-calibrating session range model[/b] — every completed session range is ranked as a percentile of that session's own trailing distribution. The active session shows a live read: current range, % of its median, and the percentile it has already reached. No pip or point thresholds, no magic numbers — the model adapts to any symbol and timeframe by construction.
[*][b]Session liquidity state machine[/b] — each session's High and Low arm at session close and are then tracked through explicit states: armed → swept → rejected or accepted. A sweep is only registered on a confirmed bar; the rejection read compares the sweep bar's close against the level. Levels that survive until the next same-session open are marked expired.
[*][b]Measured base rates[/b] — the panel reports observed frequencies from the loaded history: how often London actually sweeps the Asia High or Low on this chart, how often New York sweeps the London extremes, and how often price closes back inside after each sweep. These are counted events with the sample size shown (n), not assumptions — and below a minimum sample the panel says "collecting" instead of quoting a percentage.
[*]Three configurable sessions (Asia, London, New York) with per-session IANA timezones, so daylight-saving shifts are handled automatically.
[*]Previous Day High / Low tracked through the same armed → swept state machine.
[*]Day separators, per-session colors, and a compact statistics panel.
[/list]

[b]Core Concept — what is original here[/b]

Session boxes are common. The original contribution of this script is that it treats the session map as a [i]measurement problem[/i]:

1. [b]Percentile-ranked session ranges.[/b] A "big" or "quiet" session is only meaningful relative to that session's own recent distribution. Ranking the live range against the last N completed ranges of the same session produces a self-calibrating expansion read that works identically on FX majors, indices, or crypto — without any instrument-specific settings.

2. [b]A liquidity state machine instead of static lines.[/b] Session extremes are treated as objects with a lifecycle (armed, swept, rejected/accepted, expired). Because state transitions happen only on confirmed bars, the sweep history you see on the chart is exactly the history the statistics are built from.

3. [b]Base rates instead of narratives.[/b] The common claims about session behavior ("London takes out the Asia range", "the sweep reverses") become testable numbers here. A counted event is strictly defined: a sweep is the first confirmed-bar break of an armed level while the later session is active, and it counts as "rejected" when the sweep bar closes back inside the level. On some instruments the measured frequencies are strongly asymmetric; on others (for example 24/7 crypto) they hover near a coin flip — and the panel will honestly show you that. The point is to replace assumption with measurement on the exact chart you trade.

[b]Anatomy of the Display[/b]
[list]
[*][b]Session boxes[/b] — one box per session per day, labelled with the session name; completed boxes append the final range and its percentile (e.g. "LONDON 0.00421 · P63").
[*][b]Level lines[/b] — each session's High/Low extends right from the moment it arms at session close. A red ✕ mark shows where it was swept. Untouched levels turn dotted when they expire at the next same-session open.
[*][b]PDH / PDL[/b] — dashed lines for the previous day's extremes, same sweep marking.
[*][b]Statistics panel[/b] — one row per session (live or last range + percentile, and the state of its levels; states shown during a live session are prefixed "prev" because they belong to the previous cycle), followed by the measured base-rate block with sample sizes.
[/list]

[b]Notes on Repainting[/b]
[list]
[*]Sweep events, rejection reads, base-rate counters and all alerts fire on [b]confirmed bars only[/b] and do not repaint.
[*]Session boxes, the live range and the live percentile update intrabar while a session is open — they are visual context for the current session, not signals.
[*]No security() calls, no lookahead: everything is computed from the chart's own bars.
[*]Boxes and level lines are drawing objects anchored to past bars by design (a session box spans its session, a level line starts at the bar of the extreme). This affects only how history is displayed, never the event logic.
[/list]

[b]Typical Analysis Workflow[/b]
[list]
[*]Check the panel: how much of its typical range has the active session already used? A session at 40% of median is quiet by its own history; one at P90 has already been unusually wide for that session. These numbers describe the distribution so far — they do not predict what the next bar will do.
[*]Watch the armed levels from the prior session and the previous day: they are the objective reference points the state machine is tracking.
[*]When a sweep prints, read the rejection/acceptance tag and compare it with the measured base rate for that exact scenario on this chart.
[/list]

[b]Configuration[/b]
[list]
[*]Session hours and timezone per session (defaults: Tokyo 09:00–18:00 JST, London 08:00–17:00 UK, New York 09:30–16:00 ET). Futures/FX traders can widen them or repurpose a slot as a killzone.
[*]Rendering depth, box transparency, day separators, PDH/PDL on/off.
[*]Sweep marks: Minimal (small ✕ text) or Pill, and how many days of marks to keep.
[*]Stats lookback (sessions) for the percentile model; panel position and text size.
[/list]

[b]Markets and Timeframes[/b]
Intraday timeframes only (the script tells you if the chart is not intraday). Best readability from 5m to 1h. Works on FX, indices, futures, stocks and crypto — on 24/7 markets the session definitions matter more than the defaults, so adjust the hours to your venue.

[b]Alerts[/b]
[list]
[*]Liquidity swept — any session extreme or PDH/PDL taken (confirmed bar). The alert() message names the exact level and outcome, e.g. "EURUSD 60 — liquidity swept: ASIA H (rejected)".
[*]Session range expansion — the active session crossed the 80th percentile of its own history.
[*]Session opened.
[/list]

This is a visual analytical tool for chart reading and session-structure context. It does not generate buy/sell signals, does not execute trades, and does not provide financial advice.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//@version=6
//
// Session Liquidity Architecture [MQLSoftware]
//
// Reads the trading day as a repeating structure of sessions and MEASURES how this
// specific instrument behaves inside it, instead of restating fixed session folklore.
// Original contribution (three algorithmic elements on top of the session-box base):
//   1. Self-calibrating session range model — every completed session range is ranked
//      as a percentile of that session's own trailing distribution. No pip/point
//      thresholds, no magic numbers; the read adapts per symbol and timeframe.
//   2. Session liquidity state machine — each session's High/Low arms at session close
//      and is tracked armed → swept → rejected/accepted (confirmed bars only), the same
//      arm/trigger discipline used across the MQLSoftware line.
//   3. Measured base rates — the panel reports how often one session actually sweeps the
//      previous session's extremes on THIS chart's history, and how often price closes
//      back inside after the sweep. Observed frequencies, not assumptions.
//
// Repaint policy: sweep events, rejection reads, base-rate counters and alerts fire on
// CONFIRMED bars only. Boxes, live range and the live percentile update intrabar —
// they are visual context, not signals.

indicator("Session Liquidity Architecture [MQLSoftware]", shorttitle="MQLSoftware - Session Liquidity Architecture", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── CONSTANTS ────────────────────────────────────────────────────────────────
// Neo Slate design tokens — MQLSoftware brand palette
color NS_WHITE = color.rgb(225, 230, 240)
color NS_LBL   = color.rgb(170, 178, 195)
color NS_SEC   = color.rgb( 90,  98, 115)
color NS_BG    = color.new(color.rgb(  8, 11, 18),  4)
color NS_ROW   = color.new(color.rgb( 16, 20, 30),  6)
color NS_SWEEP = color.rgb(255,  70, 105)
color NS_AMBER = color.rgb(255, 175,  20)
color NS_INK   = color.rgb( 10,  14,  22)

color ASIA_DEF = #26C6DA  // Asia — cyan
color LDN_DEF  = #FFAF14  // London — amber
color NY_DEF   = #A78BFA  // New York — violet

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string GRP_A  = "◆ Asia Session"
var string GRP_L  = "◆ London Session"
var string GRP_N  = "◆ New York Session"
var string GRP_R  = "◆ Rendering"
var string GRP_LQ = "◆ Session Liquidity"
var string GRP_ST = "◆ Statistics & Panel"

var TZ_OPTS = "Timezone of the session hours. Uses IANA zones, so DST shifts are handled automatically."

bool   asiaOn  = input.bool   (true,        "Enable", group = GRP_A, inline = "a1")
color  asiaCol = input.color  (ASIA_DEF,    "",       group = GRP_A, inline = "a1")
string asiaSes = input.session("0900-1800", "Hours",  group = GRP_A, inline = "a2")
string asiaTz  = input.string ("Asia/Tokyo", "",      group = GRP_A, inline = "a2", tooltip = TZ_OPTS,
     options = ["Asia/Tokyo", "Asia/Shanghai", "Asia/Singapore", "Asia/Hong_Kong", "Australia/Sydney", "Europe/London", "Europe/Berlin", "Europe/Moscow", "America/New_York", "America/Chicago", "UTC"])

bool   lonOn   = input.bool   (true,          "Enable", group = GRP_L, inline = "l1")
color  lonCol  = input.color  (LDN_DEF,       "",       group = GRP_L, inline = "l1")
string lonSes  = input.session("0800-1700",   "Hours",  group = GRP_L, inline = "l2")
string lonTz   = input.string ("Europe/London", "",     group = GRP_L, inline = "l2", tooltip = TZ_OPTS,
     options = ["Asia/Tokyo", "Asia/Shanghai", "Asia/Singapore", "Asia/Hong_Kong", "Australia/Sydney", "Europe/London", "Europe/Berlin", "Europe/Moscow", "America/New_York", "America/Chicago", "UTC"])

bool   nyOn    = input.bool   (true,             "Enable", group = GRP_N, inline = "n1")
color  nyCol   = input.color  (NY_DEF,           "",       group = GRP_N, inline = "n1")
string nySes   = input.session("0930-1600",      "Hours",  group = GRP_N, inline = "n2")
string nyTz    = input.string ("America/New_York", "",     group = GRP_N, inline = "n2", tooltip = TZ_OPTS,
     options = ["Asia/Tokyo", "Asia/Shanghai", "Asia/Singapore", "Asia/Hong_Kong", "Australia/Sydney", "Europe/London", "Europe/Berlin", "Europe/Moscow", "America/New_York", "America/Chicago", "UTC"])

bool showBoxes  = input.bool(true, "Session Boxes",           group = GRP_R)
int  boxTransp  = input.int (88,   "Box Fill Transparency",   group = GRP_R, minval = 50, maxval = 100)
int  daysBack   = input.int (10,   "Days of History to Draw", group = GRP_R, minval = 1, maxval = 60,
     tooltip = "Older boxes, level lines and sweep marks are removed beyond this depth. Statistics still use the full stats lookback.")
bool showDaySep = input.bool(true, "Day Separators",          group = GRP_R)
bool showPD     = input.bool(true, "Previous Day High / Low", group = GRP_R)
bool glowOn     = input.bool(true, "Glow Effects",            group = GRP_R,
     tooltip = "Soft underglow beneath liquidity level lines. Purely cosmetic.")
string boxTxtSz = input.string("Small", "Box Text Size",      group = GRP_R, options = ["Tiny", "Small", "Normal"])

bool trackLevels = input.bool(true, "Track Session High / Low as Liquidity", group = GRP_LQ,
     tooltip = "Each session's High and Low arm at session close and extend right until swept (armed → swept → rejected/accepted) or until the next same-session close (expired).")
bool   showSweeps  = input.bool  (true,      "Sweep Marks", group = GRP_LQ, inline = "sw")
string sweepStyle  = input.string("Minimal", "",            group = GRP_LQ, inline = "sw", options = ["Minimal", "Pill"],
     tooltip = "Minimal = small colored ✕ text only. Pill = filled label. Minimal keeps the chart readable when sweeps are frequent (24/7 markets).")
int    sweepDays   = input.int   (2,         "Sweep Marks — Days Back", group = GRP_LQ, minval = 1, maxval = 60,
     tooltip = "Sweep marks older than this are removed. Level lines and statistics are not affected.")

int    statsLookback = input.int(60, "Stats Lookback (sessions)", group = GRP_ST, minval = 10, maxval = 300,
     tooltip = "How many completed sessions feed the range percentile model. Base rates accumulate over the full loaded history.")
bool   showPanel = input.bool  (true,        "Statistics Panel", group = GRP_ST)
string panelPos  = input.string("Top Right", "Position",  group = GRP_ST, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
string panelSize = input.string("Normal",    "Text Size", group = GRP_ST, options = ["Tiny", "Small", "Normal"])

string BOX_TS = boxTxtSz == "Tiny" ? size.tiny : boxTxtSz == "Small" ? size.small : size.normal

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

// Percentile rank of v inside a: % of stored values <= v
f_prank(array<float> a, float v) =>
    int n = a.size()
    if n == 0 or na(v)
        float(na)
    else
        int cnt = 0
        for i = 0 to n - 1
            if a.get(i) <= v
                cnt += 1
        100.0 * cnt / n

// Below minN the sample is too small to quote a percentage — say so instead of
// printing statistical noise.
f_rate(int c, int n, int minN = 20) =>
    n >= minN ? str.tostring(100.0 * c / n, "#") + "%" : "collecting"

f_trimBoxes(array<box> a, int maxN) =>
    while a.size() > maxN
        box.delete(a.shift())

f_trimLines(array<line> a, int maxN) =>
    while a.size() > maxN
        line.delete(a.shift())

f_trimLabels(array<label> a, int maxN) =>
    while a.size() > maxN
        label.delete(a.shift())

// ─── SESSION ENGINE ───────────────────────────────────────────────────────────
type SessInfo
    bool   on
    string name
    color  col
    bool   active
    float  liveRange
    float  medRange
    float  livePct
    float  lastRange
    float  lastPct
    int    nRanges
    int    hiState   // 0 none · 1 armed · 2 swept · 3 expired
    int    loState
    float  hiLvl
    float  loLvl
    string hiNote
    string loNote

// One call site per session — `var` state inside is instantiated per call site.
f_session(bool on, string name, string sesStr, string tzStr, color col, string tValign) =>
    var array<float> ranges = array.new<float>()
    var array<box>   boxes  = array.new<box>()
    var array<line>  lns    = array.new<line>()
    var array<label> lbls   = array.new<label>()
    var box    bx      = box(na)
    var float  hi      = na
    var float  lo      = na
    var int    hiBar   = na
    var int    loBar   = na
    var line   hiLn    = line(na)
    var line   loLn    = line(na)
    var line   hiGlow  = line(na)
    var line   loGlow  = line(na)
    var label  hiTag   = label(na)
    var label  loTag   = label(na)
    var int    hiState = 0
    var int    loState = 0
    var float  hiLvl   = na
    var float  loLvl   = na
    var string hiNote  = "—"
    var string loNote  = "—"
    var float  lastRange = na
    var float  lastPct   = na

    bool inSess = on and timeframe.isintraday and not na(time(timeframe.period, sesStr, tzStr))
    bool opened = inSess and not inSess[1]
    bool closed = not inSess and inSess[1]

    bool hiSweptNow = false
    bool loSweptNow = false
    bool hiRejNow   = false
    bool loRejNow   = false

    if opened
        // yesterday's levels that were never swept expire when a fresh session starts
        if hiState == 1 and not na(hiLn)
            hiState := 3
            hiNote  := "expired"
            hiLn.set_style(line.style_dotted)
            hiLn.set_color(color.new(col, 80))
            if not na(hiGlow)
                hiGlow.set_color(color.new(col, 96))
            label.delete(hiTag)
        if loState == 1 and not na(loLn)
            loState := 3
            loNote  := "expired"
            loLn.set_style(line.style_dotted)
            loLn.set_color(color.new(col, 80))
            if not na(loGlow)
                loGlow.set_color(color.new(col, 96))
            label.delete(loTag)
        hi    := high
        lo    := low
        hiBar := bar_index
        loBar := bar_index
        if showBoxes
            bx := box.new(bar_index, high, bar_index, low, border_color = color.new(col, 20), border_width = 2, bgcolor = color.new(col, boxTransp), text = name, text_color = color.new(col, 15), text_size = BOX_TS, text_halign = text.align_left, text_valign = tValign)
            boxes.push(bx)
            f_trimBoxes(boxes, daysBack)

    if inSess and not opened
        if high > hi
            hi    := high
            hiBar := bar_index
        if low < lo
            lo    := low
            loBar := bar_index

    if inSess and not na(bx)
        bx.set_right(bar_index)
        bx.set_top(hi)
        bx.set_bottom(lo)

    float liveRange = inSess ? hi - lo : na
    float livePct   = inSess ? f_prank(ranges, liveRange) : na
    float medRange  = ranges.size() > 0 ? ranges.median() : na

    // range expansion event: live range crosses its own 80th percentile (confirmed)
    bool expandNow = inSess and barstate.isconfirmed and not na(livePct) and livePct >= 80 and nz(livePct[1], 0) < 80

    if closed
        lastRange := hi - lo
        lastPct   := f_prank(ranges, lastRange)
        ranges.push(lastRange)
        if ranges.size() > statsLookback
            ranges.shift()
        if showBoxes and not na(bx)
            bx.set_text(name + "  " + f_px(lastRange) + (na(lastPct) ? "" : "  ·  P" + str.tostring(lastPct, "#")))
            bx.set_border_width(1)
            bx.set_border_color(color.new(col, 60))
        if trackLevels
            hiLvl   := hi
            loLvl   := lo
            hiState := 1
            loState := 1
            hiNote  := "armed"
            loNote  := "armed"
            hiLn := line.new(hiBar, hi, bar_index, hi, color = color.new(col, 15), width = 1)
            loLn := line.new(loBar, lo, bar_index, lo, color = color.new(col, 15), width = 1)
            lns.push(hiLn)
            lns.push(loLn)
            if glowOn
                hiGlow := line.new(hiBar, hi, bar_index, hi, color = color.new(col, 82), width = 5)
                loGlow := line.new(loBar, lo, bar_index, lo, color = color.new(col, 82), width = 5)
                lns.push(hiGlow)
                lns.push(loGlow)
            label.delete(hiTag)
            label.delete(loTag)
            hiTag := label.new(bar_index, hi, name + " H", style = label.style_label_left, color = color.new(col, 100), textcolor = col, size = size.tiny)
            loTag := label.new(bar_index, lo, name + " L", style = label.style_label_left, color = color.new(col, 100), textcolor = col, size = size.tiny)
            f_trimLines(lns, daysBack * 4)

    // armed levels extend right; sweep + rejection read on confirmed bars only
    if hiState == 1 and not na(hiLn)
        hiLn.set_x2(bar_index)
        if glowOn and not na(hiGlow)
            hiGlow.set_x2(bar_index)
        if not na(hiTag)
            hiTag.set_x(bar_index)
        if barstate.isconfirmed and high > hiLvl
            hiState    := 2
            hiSweptNow := true
            hiRejNow   := close < hiLvl
            hiNote     := "swept " + str.format_time(time, "HH:mm", tzStr) + (hiRejNow ? " · rejected" : " · accepted")
            label.delete(hiTag)
            if showSweeps
                bool pill = sweepStyle == "Pill"
                color mk  = hiRejNow ? NS_SWEEP : NS_AMBER
                lbls.push(label.new(bar_index, hiLvl, "✕ " + name + " H", style = pill ? label.style_label_down : label.style_none, color = pill ? color.new(mk, 20) : color.new(mk, 100), textcolor = pill ? NS_WHITE : mk, size = size.tiny))
                f_trimLabels(lbls, sweepDays * 2)
    if loState == 1 and not na(loLn)
        loLn.set_x2(bar_index)
        if glowOn and not na(loGlow)
            loGlow.set_x2(bar_index)
        if not na(loTag)
            loTag.set_x(bar_index)
        if barstate.isconfirmed and low < loLvl
            loState    := 2
            loSweptNow := true
            loRejNow   := close > loLvl
            loNote     := "swept " + str.format_time(time, "HH:mm", tzStr) + (loRejNow ? " · rejected" : " · accepted")
            label.delete(loTag)
            if showSweeps
                bool pill = sweepStyle == "Pill"
                color mk  = loRejNow ? NS_SWEEP : NS_AMBER
                lbls.push(label.new(bar_index, loLvl, "✕ " + name + " L", style = pill ? label.style_label_up : label.style_none, color = pill ? color.new(mk, 20) : color.new(mk, 100), textcolor = pill ? NS_WHITE : mk, size = size.tiny))
                f_trimLabels(lbls, sweepDays * 2)

    SessInfo info = SessInfo.new(on, name, col, inSess, liveRange, medRange, livePct, lastRange, lastPct, ranges.size(), hiState, loState, hiLvl, loLvl, hiNote, loNote)
    [info, opened, closed, hiSweptNow, loSweptNow, hiRejNow, loRejNow, expandNow]

// London is labelled at the box bottom — it overlaps both Asia and New York in price,
// so alternating the label edge prevents box-text collisions.
[aInfo, aOp, aCl, aHiSw, aLoSw, aHiRej, aLoRej, aExp] = f_session(asiaOn, "ASIA",     asiaSes, asiaTz, asiaCol, text.align_top)
[lInfo, lOp, lCl, lHiSw, lLoSw, lHiRej, lLoRej, lExp] = f_session(lonOn,  "LONDON",   lonSes,  lonTz,  lonCol,  text.align_bottom)
[nInfo, nOp, nCl, nHiSw, nLoSw, nHiRej, nLoRej, nExp] = f_session(nyOn,   "NEW YORK", nySes,   nyTz,   nyCol,   text.align_top)

// ─── BASE RATES ───────────────────────────────────────────────────────────────
// Measured on this chart's own history: did session Y sweep session X's extremes,
// and did price close back inside on the sweep bar (rejected) or not (accepted).

// London vs Asia levels
var int  nLdn    = 0
var int  cLdnAH  = 0
var int  cLdnAL  = 0
var int  cRejAH  = 0
var int  cRejAL  = 0
var bool fAH     = false
var bool fAL     = false
var bool fRejAH  = false
var bool fRejAL  = false
if lOp
    fAH    := false
    fAL    := false
    fRejAH := false
    fRejAL := false
if aHiSw and lInfo.active
    fAH    := true
    fRejAH := aHiRej
if aLoSw and lInfo.active
    fAL    := true
    fRejAL := aLoRej
if lCl
    nLdn += 1
    if fAH
        cLdnAH += 1
        if fRejAH
            cRejAH += 1
    if fAL
        cLdnAL += 1
        if fRejAL
            cRejAL += 1

// New York vs London levels
var int  nNyk    = 0
var int  cNyLH   = 0
var int  cNyLL   = 0
var int  cRejLH  = 0
var int  cRejLL  = 0
var bool fLH     = false
var bool fLL     = false
var bool fRejLH  = false
var bool fRejLL  = false
if nOp
    fLH    := false
    fLL    := false
    fRejLH := false
    fRejLL := false
if lHiSw and nInfo.active
    fLH    := true
    fRejLH := lHiRej
if lLoSw and nInfo.active
    fLL    := true
    fRejLL := lLoRej
if nCl
    nNyk += 1
    if fLH
        cNyLH += 1
        if fRejLH
            cRejLH += 1
    if fLL
        cNyLL += 1
        if fRejLL
            cRejLL += 1

// ─── PREVIOUS DAY HIGH / LOW ──────────────────────────────────────────────────
var float  pdh      = na
var float  pdl      = na
var float  dayH     = na
var float  dayL     = na
var line   pdhLn    = line(na)
var line   pdlLn    = line(na)
var line   pdhGlow  = line(na)
var line   pdlGlow  = line(na)
var label  pdhTag   = label(na)
var label  pdlTag   = label(na)
var int    pdhState = 0
var int    pdlState = 0
var array<line>  pdLns  = array.new<line>()
var array<label> pdLbls = array.new<label>()

bool newDay = timeframe.isintraday and timeframe.change("D")
bool pdhSw  = false
bool pdlSw  = false

if showPD
    if newDay
        if pdhState == 1 and not na(pdhLn)
            pdhLn.set_style(line.style_dotted)
            pdhLn.set_color(color.new(NS_SEC, 60))
            if not na(pdhGlow)
                pdhGlow.set_color(color.new(NS_WHITE, 97))
        if pdlState == 1 and not na(pdlLn)
            pdlLn.set_style(line.style_dotted)
            pdlLn.set_color(color.new(NS_SEC, 60))
            if not na(pdlGlow)
                pdlGlow.set_color(color.new(NS_WHITE, 97))
        label.delete(pdhTag)
        label.delete(pdlTag)
        pdh  := dayH
        pdl  := dayL
        dayH := high
        dayL := low
        if not na(pdh)
            pdhLn := line.new(bar_index, pdh, bar_index + 1, pdh, color = color.new(NS_WHITE, 55), style = line.style_dashed)
            pdLns.push(pdhLn)
            if glowOn
                pdhGlow := line.new(bar_index, pdh, bar_index + 1, pdh, color = color.new(NS_WHITE, 90), width = 4)
                pdLns.push(pdhGlow)
            pdhTag := label.new(bar_index + 1, pdh, "PDH", style = label.style_label_left, color = color.new(NS_WHITE, 100), textcolor = color.new(NS_WHITE, 40), size = size.tiny)
            pdhState := 1
        if not na(pdl)
            pdlLn := line.new(bar_index, pdl, bar_index + 1, pdl, color = color.new(NS_WHITE, 55), style = line.style_dashed)
            pdLns.push(pdlLn)
            if glowOn
                pdlGlow := line.new(bar_index, pdl, bar_index + 1, pdl, color = color.new(NS_WHITE, 90), width = 4)
                pdLns.push(pdlGlow)
            pdlTag := label.new(bar_index + 1, pdl, "PDL", style = label.style_label_left, color = color.new(NS_WHITE, 100), textcolor = color.new(NS_WHITE, 40), size = size.tiny)
            pdlState := 1
        f_trimLines(pdLns, daysBack * 4)
    else
        dayH := na(dayH) ? high : math.max(dayH, high)
        dayL := na(dayL) ? low  : math.min(dayL, low)

    if pdhState == 1 and not na(pdhLn)
        pdhLn.set_x2(bar_index)
        if glowOn and not na(pdhGlow)
            pdhGlow.set_x2(bar_index)
        if not na(pdhTag)
            pdhTag.set_x(bar_index)
        if barstate.isconfirmed and high > pdh
            pdhState := 2
            pdhSw    := true
            label.delete(pdhTag)
            if showSweeps
                bool pill = sweepStyle == "Pill"
                color mk  = close < pdh ? NS_SWEEP : NS_AMBER
                pdLbls.push(label.new(bar_index, pdh, "✕ PDH", style = pill ? label.style_label_down : label.style_none, color = pill ? color.new(mk, 20) : color.new(mk, 100), textcolor = pill ? NS_WHITE : mk, size = size.tiny))
                f_trimLabels(pdLbls, sweepDays * 2)
    if pdlState == 1 and not na(pdlLn)
        pdlLn.set_x2(bar_index)
        if glowOn and not na(pdlGlow)
            pdlGlow.set_x2(bar_index)
        if not na(pdlTag)
            pdlTag.set_x(bar_index)
        if barstate.isconfirmed and low < pdl
            pdlState := 2
            pdlSw    := true
            label.delete(pdlTag)
            if showSweeps
                bool pill = sweepStyle == "Pill"
                color mk  = close > pdl ? NS_SWEEP : NS_AMBER
                pdLbls.push(label.new(bar_index, pdl, "✕ PDL", style = pill ? label.style_label_up : label.style_none, color = pill ? color.new(mk, 20) : color.new(mk, 100), textcolor = pill ? NS_WHITE : mk, size = size.tiny))
                f_trimLabels(pdLbls, sweepDays * 2)

// ─── DAY SEPARATORS ───────────────────────────────────────────────────────────
var array<line> seps = array.new<line>()
if showDaySep and newDay
    seps.push(line.new(bar_index, close, bar_index, close + syminfo.mintick, extend = extend.both, color = color.new(NS_SEC, 55), style = line.style_dotted))
    f_trimLines(seps, daysBack)

// ─── PANEL ────────────────────────────────────────────────────────────────────
// 5-block meter for a percentile value — instant visual read in the panel
f_blocks(float p) =>
    na(p) ? "" : p >= 90 ? "  ▰▰▰▰▰" : p >= 70 ? "  ▰▰▰▰▱" : p >= 50 ? "  ▰▰▰▱▱" : p >= 30 ? "  ▰▰▱▱▱" : p >= 10 ? "  ▰▱▱▱▱" : "  ▱▱▱▱▱"

f_rangeStr(SessInfo s) =>
    if s.active
        string med = na(s.medRange) or s.medRange == 0 ? "" : "  ·  " + str.tostring(100 * s.liveRange / s.medRange, "#") + "% of median"
        "LIVE  " + f_px(s.liveRange) + med + f_blocks(s.livePct)
    else
        na(s.lastRange) ? "—" : f_px(s.lastRange) + (na(s.lastPct) ? "" : "  ·  P" + str.tostring(s.lastPct, "#") + f_blocks(s.lastPct))

// During an active session the displayed level states belong to the PREVIOUS cycle
// (fresh levels only arm at session close) — prefix them so the panel can't mislead.
f_liqStr(SessInfo s) =>
    s.hiState == 0 ? (s.active ? "forming" : "—") : (s.active ? "prev  " : "") + "H " + s.hiNote + "   L " + s.loNote

var table pnl = table(na)
if barstate.islast
    if not na(pnl)
        table.delete(pnl)
    if not timeframe.isintraday
        pnl := table.new(position.middle_center, 1, 1, bgcolor = NS_BG)
        pnl.cell(0, 0, "Session Liquidity Architecture — intraday timeframes only", text_color = NS_WHITE, text_size = size.small)
    else if showPanel
        string pPos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left
        string pSz  = panelSize == "Tiny" ? size.tiny : panelSize == "Small" ? size.small : size.normal
        pnl := table.new(pPos, 3, 10, bgcolor = NS_BG, border_width = 1, border_color = color.new(NS_SEC, 80))
        pnl.cell(0, 0, "SESSION LIQUIDITY ARCHITECTURE", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
        pnl.merge_cells(0, 0, 2, 0)
        int row = 1
        for s in array.from(aInfo, lInfo, nInfo)
            if s.on
                pnl.cell(0, row, s.name,        text_color = NS_INK,   text_size = pSz, text_halign = text.align_left,  bgcolor = color.new(s.col, 15))
                pnl.cell(1, row, f_rangeStr(s), text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left,  bgcolor = s.active ? color.new(s.col, 90) : NS_ROW)
                pnl.cell(2, row, f_liqStr(s),   text_color = NS_LBL,   text_size = pSz, text_halign = text.align_left,  bgcolor = NS_ROW)
                row += 1
        pnl.cell(0, row, "BASE RATES · measured on this chart", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left, tooltip = "Counted on confirmed bars over the loaded history. Sweep = first break of an armed session extreme while the later session is active. Rejected = the sweep bar closed back inside the level. Percentages appear once the sample reaches 20 sessions (10 sweeps for the rejection share).")
        pnl.merge_cells(0, row, 2, row)
        row += 1
        if lonOn and asiaOn
            pnl.cell(0, row, "LDN sweeps ASIA H", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            pnl.cell(1, row, f_rate(cLdnAH, nLdn) + "  (n=" + str.tostring(nLdn) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
            pnl.cell(2, row, "→ rejected " + f_rate(cRejAH, cLdnAH, 10), text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            row += 1
            pnl.cell(0, row, "LDN sweeps ASIA L", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            pnl.cell(1, row, f_rate(cLdnAL, nLdn) + "  (n=" + str.tostring(nLdn) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
            pnl.cell(2, row, "→ rejected " + f_rate(cRejAL, cLdnAL, 10), text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            row += 1
        if nyOn and lonOn
            pnl.cell(0, row, "NY sweeps LDN H", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            pnl.cell(1, row, f_rate(cNyLH, nNyk) + "  (n=" + str.tostring(nNyk) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
            pnl.cell(2, row, "→ rejected " + f_rate(cRejLH, cNyLH, 10), text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            row += 1
            pnl.cell(0, row, "NY sweeps LDN L", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            pnl.cell(1, row, f_rate(cNyLL, nNyk) + "  (n=" + str.tostring(nNyk) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
            pnl.cell(2, row, "→ rejected " + f_rate(cRejLL, cNyLL, 10), text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
            row += 1

// ─── ALERTS ───────────────────────────────────────────────────────────────────
bool anySweep  = aHiSw or aLoSw or lHiSw or lLoSw or nHiSw or nLoSw or pdhSw or pdlSw
bool anyExpand = aExp or lExp or nExp
bool anyOpen   = aOp or lOp or nOp

// Rich sweep notification — names the exact level(s) and outcome. Fires only on
// confirmed bars (the events themselves are confirmed-gated).
if anySweep
    array<string> parts = array.new<string>()
    if aHiSw
        parts.push("ASIA H (" + (aHiRej ? "rejected" : "accepted") + ")")
    if aLoSw
        parts.push("ASIA L (" + (aLoRej ? "rejected" : "accepted") + ")")
    if lHiSw
        parts.push("LONDON H (" + (lHiRej ? "rejected" : "accepted") + ")")
    if lLoSw
        parts.push("LONDON L (" + (lLoRej ? "rejected" : "accepted") + ")")
    if nHiSw
        parts.push("NY H (" + (nHiRej ? "rejected" : "accepted") + ")")
    if nLoSw
        parts.push("NY L (" + (nLoRej ? "rejected" : "accepted") + ")")
    if pdhSw
        parts.push("PDH")
    if pdlSw
        parts.push("PDL")
    alert(syminfo.ticker + " " + timeframe.period + " — liquidity swept: " + parts.join(", "), alert.freq_once_per_bar_close)

alertcondition(anySweep,  "Liquidity swept",          "A session or previous-day extreme was swept (confirmed bar) — see the ✕ label on the chart")
alertcondition(anyExpand, "Session range expansion",  "The active session's range crossed the 80th percentile of its own history")
alertcondition(anyOpen,   "Session opened",           "A tracked session just opened")
````

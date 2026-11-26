# Opening Range Breakout & Liquidity Engine

- url: https://www.tradingview.com/script/9uSslGcR-Opening-Range-Breakout-Liquidity-Engine/
- type: indicator
- pine_id: PUB;a92dab5ffa004a2b8bbf4f4c88936ad1
- version: 2.0

## Description

Opening Range Breakout & Liquidity Engine 

Overview

A complete intraday opening-range-breakout engine. For each session it auto-detects the open, builds the opening range (the high–low band of the first N minutes, where the day's initial balance is set), and then does the three things most opening-range scripts leave out: it filters the day for tradability, it projects a trade map (targets and a stop) scaled to that day's own volatility, and it keeps an honest, on-chart win-rate tally of how often breaks actually reach their first target before the stop. It draws the structure and the map; it does not place orders. Analytical tool, not advice.

What makes it different — why these pieces are ONE engine (mashup rationale)

The opening range is the substrate — the reference band the whole day is measured against (ORH / ORL / midpoint).
The relative-volume ("in play") filter asks whether the range formed on above-average volume — the single biggest edge driver in the research. A break on a quiet day and a break on an active day are not the same event, so the engine measures the range's volume against a rolling average of prior sessions' opening-range volume and flags it.
The direction filter can require the break to agree with the opening-range candle's own direction, dropping the counter-range breaks that fare worst.
The accepted-break logic (close beyond the edge, optionally held a bar) separates a real initiative move from a wick.
The trade map projects targets (as range multiples or risk/R multiples) and a stop (opposite edge, range midpoint, or an ATR distance), so the plan scales to each day's volatility instead of fixed points — and reports the resulting R:R.
The win-rate harness closes the loop: it tracks every break until it tags target 1 or the stop and reports a real, path-aware Hit % and Edge on your instrument (optionally in-play only), logging unresolved breaks as end-of-day exits separately.
The failed-break module handles the other half of reality: a break that closes back inside the range traps breakout traders, so the engine flags it, projects the reversal to the opposite edge (stop at the failure extreme), and runs a second harness measuring how often that fade reaches the opposite edge before the failure is re-broken. A retest-hold flag marks the high-probability continuation entry; a trap flag marks both-edges-broken days; a range-state read (compressed / normal / wide) says what kind of break you're looking at.


Split apart, each piece is a fragment: a box without the filters is noise, targets without the harness are guesses, and a break with no failure case is half the picture. Chained, they answer one question — is this opening-range break worth taking here, and if it fails, is the fade? That interdependence is why it's a single engine, not a bundle.

What this adds over a standard opening-range script

Most ORB scripts stop at drawing the box and the two breakout lines. This engine adds the parts that decide and verify:


Relative-volume "in play" filter. Flags whether today's opening range formed on above-average volume — research-shown to be the dominant driver of opening-range edge — with an optional toggle to count only in-play days in the stats.
Range-direction filter. Optionally restricts breaks to the direction the opening-range candle closed, removing the weakest counter-range trades.
Volatility-scaled trade map. Targets as range or R (risk) multiples; stop at the opposite edge, the range midpoint, or an ATR distance — with the live R:R shown.
Path-aware win-rate harness. Tracks each break to target 1 or stop and reports an honest Hit % / Edge (vs a 50% coin-flip), counting end-of-day exits separately — a real, in-sample reality check, not a curve-fit claim.
Failed-break reversal module. Detects the break that closes back inside the range (a fakeout — research puts breakout failure rates in the 60–80% range), projects the fade toward the opposite edge with the failure extreme as its stop, and runs a second harness reporting how often the fade reaches that edge first. A failed break is often the better trade, and almost no ORB script measures it.
Retest-hold, trap and range-state context. A retest-hold flag marks the broken edge holding as support/resistance (the higher-probability continuation entry); a trap flag marks both-edges-broken whipsaw days; a range-state read (compressed / normal / wide vs the rolling average) says whether the break is likely to run or fail.
Reference levels with built-in legends. Current-day H/L, prior-day H/L (PDH/PDL) and prior-week H/L (PWH/PWL) — the most-watched intraday liquidity pools — are drawn as labelled lines that extend right, each tagged (DH/DL/PDH/PDL/PWH/PWL) so every line identifies itself. A Day position read shows whether price is above PDH, inside the prior-day range, or below PDL.
Liquidity-sweep detection, fused with the failure logic. A sweep — price wicks beyond PDH/PDL/PWH/PWL and closes back inside, taking the stops there — is flagged with a marker and in the dashboard. Because the opening-range edges are themselves prime liquidity, a failed ORB break that sweeps a level is the highest-conviction version of the fade; the engine ties the two together.
Institution-grade, readable visuals. Events are compact bar-anchored markers (triangle / cross / circle / flag) instead of stacked labels; key levels are drawn as glowing lines with bold colour-coded legend chips at the right edge; a legend-key panel decodes every mark and line; and only the most recent sessions' drawings are kept, so the chart stays clean even after months of history. The dashboard and legend key are theme-adaptive — they auto-match a light or dark chart background for proper contrast.
Auto-session that works where others break. New-session detection keys off a calendar-day change in the instrument's own timezone, so it resets correctly even on feeds with no out-of-session bars (NSE index futures only print 09:15–15:30) — where edge-detection scripts silently fail.
Fused decision dashboard. Break state, ORH/ORL, range, range state, range direction, relative volume / in-play, targets, stop, R:R, day position vs the prior day, liquidity-sweep status, the running Hit % / Edge, the failed-break fade and its Hit % / Edge, and retest/trap status — theme-adaptive to your chart.


How it works

Session: Auto groups by the instrument's trading day in its native timezone (works even with no out-of-session bars); Manual pins a window. Range: the high/low of the first N minutes become ORH/ORL; the midpoint is the pivot; the range candle's close-vs-open sets the range direction; its volume vs a rolling average gives the relative-volume "in play" read; its size vs a rolling average gives the range state (compressed / normal / wide). Break: the first close beyond ORH (long) or ORL (short) after the range completes, optionally held a bar and optionally restricted to the range direction. Map: targets = break edge + range multiples, or entry + risk (R) multiples; stop = opposite edge, range midpoint, or an ATR distance. Harness: each break is followed until it tags target 1 or the stop; unresolved breaks at the close are logged as end-of-day exits, separate from the Hit %. Failure: if an accepted break closes back inside the range it is flagged failed; the reversal targets the opposite edge with the failure extreme as stop, and a separate fade harness reports how often that reversal reaches the opposite edge before the failure extreme is re-broken. A retest of the broken edge that holds is flagged continuation; both edges breaking is flagged a trap. Levels: current-day H/L (tracked live), prior-day H/L and prior-week H/L (from the weekly series) are drawn as labelled lines (DH/DL, PDH/PDL, PWH/PWL) extending right. Liquidity: a sweep is a bar that wicks a set fraction of ATR beyond PDH/PDL/PWH/PWL then closes back inside — the stops there are taken and price rejects — flagged with a marker and in the dashboard alongside the day-position read.

How to use

Trade with an accepted break toward target 1 / 2, invalidated back inside the range (or at the chosen stop); favour in-play, range-direction and compressed-range breaks, and breaks that also clear PDH / PWH (genuine acceptance through liquidity) — all shown to carry the edge. When a break fails back inside, or sweeps a key level and rejects, the fade toward the opposite edge is often the better trade — the dashboard's fade Hit % / Edge tells you whether it has paid here. A retest that holds confirms continuation; a trap (both edges broken) is usually a stand-aside. Use the Hit % / Edge reads as a reality check before relying on any of it. Context for your decisions — not a standalone trigger.

Universal across markets (configurable data source)

High / low / close sources, the session mode / window / timezone and the range length are all inputs, so the engine runs on any instrument and intraday timeframe. Defaults target NSE NIFTY index futures with a first-15-minute range (the research tested 5 / 15 / 30 / 60 minutes; 5 was best on US single stocks). Change the sources, session and range for any other market. Use an intraday chart; the relative-volume filter needs a real volume feed and degrades gracefully without one.

Originality

The opening-range, fakeout-reversal and liquidity concepts are public (credited below); the original work is the assembly and the code — auto-session detection that works on instruments with no out-of-session bars, the relative-volume "in play" / range-direction / range-state filters, the range / R-multiple trade map with ATR stop and end-of-day exit, the path-aware win-rate harness, the failed-break reversal module with its own fade harness, and the reference-level + liquidity-sweep engine that ties the break to prior-day / prior-week liquidity. No third-party code is reused.

Companion drawings (TradingView compliance note)

Everything this plots is part of the one engine and is explained above — the opening-range box, the ORH/ORL/midpoint lines, the day/week reference levels (DH/DL, PDH/PDL, PWH/PWL) with their right-edge legends, the bar-anchored break / failed / retest / sweep markers, the target / stop / reversal lines, the legend-key panel, and the dashboard. There are no unrelated studies. Before publishing, clean the chart so only this indicator is shown.

Concept credit

The opening-range-breakout concept is long-standing market lore, formalised by Toby Crabel ("Day Trading with Short Term Price Patterns and Opening Range Breakout") and related to Mark B. Fisher's ACD method ("The Logical Trader"). The relative-volume "stocks in play" filter and the range-direction entry follow the empirical study of Zarattini, Barbon & Aziz (2023–24). The failed-breakout (fakeout) reversal and retest-hold continuation are classic price-action concepts, and prior-day / prior-week liquidity with the liquidity-sweep (stop-raid-then-reject) read are general price-action / Smart-Money-Concept ideas in wide public use. Implementation is original; not affiliated with, nor endorsed by, any third party, and no third-party code is reused.

Honesty / limitations

The Hit % is path-aware but in-sample, ignores costs and slippage, assumes the target/stop fills exactly at touch, and counts one break per session — descriptive context, not a verified backtest. Opening-range behaviour varies by instrument, session and regime. This engine maps structure; it does not predict which breaks will work.

Disclaimer

Research / educational only. NOT financial advice; no guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// OPENING RANGE BREAKOUT & LIQUIDITY ENGINE                                               v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
//   Marks the opening range, the first accepted break, the failed-break fade, retest-hold and
//   trap context, the day/week reference levels and their liquidity sweeps. Targets and stops are
//   computed INTERNALLY to drive the path-aware win-rate harness (Hit % / Edge) and are reported
//   in the dashboard, but are NOT drawn as lines on the chart in this build. Analytical tool, not
//   advice. NOT financial advice; no guarantee of profitability or accuracy.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Opening Range Breakout & Liquidity Engine", "ORB", overlay = true, max_lines_count = 500, max_boxes_count = 200, max_labels_count = 200)

// ── 01 · DATA & SESSION ─────────────────────────────────────────────────────────────────
g0 = "01 · Data & session"
srcH = input.source(high,  "High source", group = g0)
srcL = input.source(low,   "Low source",  group = g0)
srcC = input.source(close, "Close source", group = g0)
sesMode = input.string("Auto (from chart)", "Session detection", options = ["Auto (from chart)","Manual session"], group = g0,
     tooltip = "Auto groups by the instrument's own trading day in its native timezone (works even with no out-of-session bars). Manual pins an explicit window.")
sesStr  = input.session("0915-1530", "Manual session window", group = g0, tooltip = "Used only in Manual mode. Default suits NSE RTH.")
sesTz   = input.string("Asia/Kolkata", "Manual session timezone", group = g0, tooltip = "Used only in Manual mode.")

// ── 02 · OPENING RANGE ──────────────────────────────────────────────────────────────────
g1 = "02 · Opening range"
orMins  = input.int(15, "Range length (minutes)", minval = 1, maxval = 240, group = g1, tooltip = "Minutes from the session open that define the opening range. 15 min suits NSE index futures; the research tested 5 / 15 / 30 / 60 (5 min was best on US single stocks). Change to taste.")
holdBar = input.bool(false, "Require a confirmation bar", group = g1, tooltip = "If on, a break needs the close to hold beyond the edge for one extra bar before it counts.")
keepSes = input.int(5, "Sessions to keep drawn", minval = 1, maxval = 30, group = g1)

// ── 03 · ACTIVITY & DIRECTION FILTER ────────────────────────────────────────────────────
g1b = "03 · Activity & direction filter"
biasMode = input.string("Both ways", "Break direction", options = ["Both ways","Range direction only"], group = g1b,
     tooltip = "Both ways takes the first break either side. Range direction only takes a break solely in the direction the opening-range candle closed - the research-favoured filter that drops counter-range breaks.")
useRvol = input.bool(true, "Relative-volume (in-play) filter", group = g1b,
     tooltip = "Flags whether the opening range formed on above-average volume - the 'stock in play' condition shown to be the single biggest edge driver for opening-range breakouts.")
rvolMult = input.float(1.2, "In-play threshold (x avg)", minval = 0.5, step = 0.1, group = g1b)
rvolN    = input.int(20, "Average over (sessions)", minval = 2, maxval = 100, group = g1b)
onlyInPlay = input.bool(false, "Count only in-play breaks in stats", group = g1b,
     tooltip = "If on, the win-rate harness ignores breaks on low-volume (not-in-play) days.")

// ── 04 · TRADE MAP (calibration basis — levels not drawn) ───────────────────────────────
g2 = "04 · Trade map (stats basis)"
targetMode = input.string("Range multiple", "Target basis", options = ["Range multiple","R multiple (risk)"], group = g2,
     tooltip = "Basis for the INTERNAL target/stop the win-rate harness measures against. The levels are NOT drawn on the chart in this build — they feed the Hit % / Edge stats and the dashboard's Target/Stop/R:R rows only.")
t1Mult = input.float(1.0, "Target 1 (x range / R)", minval = 0.2, step = 0.1, group = g2)
t2Mult = input.float(2.0, "Target 2 (x range / R)", minval = 0.4, step = 0.1, group = g2)
stopMode = input.string("Opposite edge", "Stop", options = ["Opposite edge","Range midpoint","ATR"], group = g2)
atrLenS  = input.int(14, "ATR length (ATR stop)", minval = 1, group = g2)
atrMultS = input.float(1.0, "ATR stop (x ATR)", minval = 0.2, step = 0.1, group = g2)

// ── 05 · FAILED BREAK & CONTEXT ─────────────────────────────────────────────────────────
g2b = "05 · Failed break & context"
showFade = input.bool(true, "Failed-break reversal", group = g2b,
     tooltip = "Detects an accepted break that closes back INSIDE the range (a fakeout that traps breakout traders), and calibrates how often that fade reaches the opposite edge before the failure extreme is re-broken. The reversal level is NOT drawn — it feeds the Fade Hit % stat only.")
showRetest = input.bool(true, "Flag retest-hold continuation", group = g2b,
     tooltip = "Flags a pullback to the broken edge that holds (closes back beyond it) - the higher-probability continuation entry in the research.")
compN = input.int(20, "Range-state average (sessions)", minval = 2, maxval = 100, group = g2b,
     tooltip = "Rolling average of opening-range size used to label today's range compressed / normal / wide. Compressed ranges tend to run on a break; already-wide ranges tend to fail.")

// ── 06 · REFERENCE LEVELS & LIQUIDITY ───────────────────────────────────────────────────
g3 = "06 · Reference levels & liquidity"
showLevels = input.bool(true, "Show day / week levels", group = g3,
     tooltip = "Plots current-day H/L, prior-day H/L (PDH/PDL) and prior-week H/L (PWH/PWL) - the most-watched intraday liquidity levels - each labelled at the right edge.")
showLiq = input.bool(true, "Liquidity-sweep detection", group = g3,
     tooltip = "Flags when price wicks beyond a key level (taking the stops resting there) and closes back inside - a sweep. A failed opening-range break that sweeps a level is a high-odds reversal.")
liqWick = input.float(0.25, "Sweep wick (x ATR beyond level)", minval = 0.05, step = 0.05, group = g3,
     tooltip = "How far beyond a level price must wick (then close back) to count as a sweep of the liquidity there.")
colDay  = input.color(#5b8def, "Day H / L", inline = "lv1", group = g3)
colPDay = input.color(#e0922e, "Prior-day H / L", inline = "lv1", group = g3)
colPWk  = input.color(#26a69a, "Prior-week H / L", group = g3)

// ── 07 · CALIBRATION HARNESS ────────────────────────────────────────────────────────────
g4 = "07 · Calibration harness"
calibOn = input.bool(true, "Run win-rate calibration", group = g4, tooltip = "Tracks each break until it tags target 1 or the stop, and reports the share that reached target 1 first (Hit %), versus a 50% coin-flip base. Edge = Hit - 50.")

// ── 08 · VISUAL STYLE ───────────────────────────────────────────────────────────────────
g5 = "08 · Visual style"
colOR   = input.color(#3a7bd5, "Opening range", group = g5)
colUp   = input.color(#2ebd85, "Long break", inline = "br", group = g5)
colDn   = input.color(#f6465d, "Short break", inline = "br", group = g5)
colTgt  = input.color(#f7c948, "Targets (stats accent)", group = g5)
colStop = input.color(#f6465d, "Stop (stats accent)", group = g5)
colFade = input.color(#b07cff, "Failed-break reversal", group = g5)
lnWidth = input.int(2, "Line thickness", minval = 1, maxval = 5, group = g5)
lvlSize = input.string("Small", "Legend text size", options = ["Tiny","Small","Normal"], group = g5)

// ── 09 · DASHBOARD & THEME ──────────────────────────────────────────────────────────────
g6 = "09 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g6)
showKey   = input.bool(true, "Show legend key", group = g6)
keyPos    = input.string("Bottom Left", "Legend key position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                         HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
f_hm(int m) => na(m) ? "--:--" : str.tostring(int(m / 60), "00") + ":" + str.tostring(m % 60, "00")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                     SESSION & RANGE
// ═════════════════════════════════════════════════════════════════════════════════════════
bool   autoSes = sesMode == "Auto (from chart)"
string dtz     = autoSes ? syminfo.timezone : sesTz
float  sesTime = time(timeframe.period, sesStr, sesTz)
bool   inSes   = autoSes ? true : not na(sesTime)
var bool wasIn = false
int   sesDom = dayofmonth(time, dtz)
bool  dayChg = sesDom != sesDom[1]
bool  newSes = inSes and (not wasIn or dayChg)
wasIn := inSes

var int   sesOpenMin = na
int barMs = timeframe.in_seconds() * 1000

var float orH = na
var float orL = na
var bool  orDone = false
var bool  broke  = false
var int   brkDir = 0
var float entryPx = na
var float t1 = na
var float t2 = na
var float stopPx = na
var int   sesT0 = na
var int   orEndT = na
var bool  pend = false
var bool  pendInPlay = false
var int   winN = 0
var int   lossN = 0
var int   timeoutN = 0
var float orVolAcc = na
var float orVolAvg = na
var float orOpen = na
var int   orDir = 0
var bool  inPlay = false
var float rvol = na
// failed-break reversal, retest, trap and range-compression state
var bool  failFlagged = false
var bool  revPend = false
var int   revDir = 0
var float revTgt = na
var float revStop = na
var float failExt = na
var int   revN = 0
var int   revHit = 0
var bool  retestHeld = false
var bool  rawUp = false
var bool  rawDn = false
var float orRng = na
var float orRngAvg = na
var float compRatio = na
// day / week reference levels and liquidity-sweep state
var float curDayHi = na
var float curDayLo = na
var float prevDayHi = na
var float prevDayLo = na
var line lnDH = na
var line lnDL = na
var line lnPDH = na
var line lnPDL = na
var line lnPWH = na
var line lnPWL = na
var line gDH = na
var line gDL = na
var line gPDH = na
var line gPDL = na
var line gPWH = na
var line gPWL = na
var label lbDH = na
var label lbDL = na
var label lbPDH = na
var label lbPDL = na
var label lbPWH = na
var label lbPWL = na
var int   sweepDir = 0
var string sweepLvl = ""
var int   sweepBar = na
// GC pools for per-session drawables (keep only the most recent sessions)
var array<box>   sBoxes = array.new<box>()
var array<line>  sLines = array.new<line>()
var array<label> sLabels = array.new<label>()

float atrV = ta.atr(atrLenS)
[pwhRaw, pwlRaw] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_off)
string lvlSz = lvlSize == "Tiny" ? size.tiny : lvlSize == "Normal" ? size.normal : size.small

// register a per-session drawable and trim whole old sessions out of the chart
f_regBox(box b) =>
    array.push(sBoxes, b)
    while array.size(sBoxes) > keepSes
        box.delete(array.shift(sBoxes))
f_regLine(line l) =>
    array.push(sLines, l)
    while array.size(sLines) > keepSes * 14
        line.delete(array.shift(sLines))
f_regLabel(label l) =>
    array.push(sLabels, l)
    while array.size(sLabels) > keepSes * 10
        label.delete(array.shift(sLabels))

// drawables for the current session (recreated each session; old ones persist and auto-GC)
var box  orBox = na
var line orhG = na
var line orhLn = na
var line orlG = na
var line orlLn = na
var line midLn = na
var label orhLb = na
var label orlLb = na

if newSes
    if pend
        timeoutN += 1
    sesOpenMin := hour(time, dtz) * 60 + minute(time, dtz)
    orH := na
    orL := na
    orDone := false
    broke := false
    brkDir := 0
    entryPx := na
    t1 := na
    t2 := na
    stopPx := na
    pend := false
    pendInPlay := false
    sesT0 := time
    orEndT := na
    orVolAcc := 0.0
    orOpen := open
    orDir := 0
    inPlay := false
    rvol := na
    failFlagged := false
    revPend := false
    revDir := 0
    revTgt := na
    revStop := na
    failExt := na
    retestHeld := false
    rawUp := false
    rawDn := false
    orRng := na
    compRatio := na
    // roll the just-completed day's high/low into the prior-day reference, then reset
    if not na(curDayHi)
        prevDayHi := curDayHi
        prevDayLo := curDayLo
    curDayHi := high
    curDayLo := low
    sweepDir := 0
    sweepLvl := ""

int curMin = na(sesOpenMin) ? na : hour(time, dtz) * 60 + minute(time, dtz)
int minSince = (na(curMin) or na(sesOpenMin)) ? na : curMin - sesOpenMin

if inSes
    curDayHi := na(curDayHi) ? high : math.max(curDayHi, high)
    curDayLo := na(curDayLo) ? low : math.min(curDayLo, low)
    // build the opening range
    if not na(minSince) and minSince < orMins
        orH := na(orH) ? srcH : math.max(orH, srcH)
        orL := na(orL) ? srcL : math.min(orL, srcL)
        orVolAcc := nz(orVolAcc) + nz(volume)
    else if not orDone and not na(orH) and not na(orL)
        orDone := true
        orEndT := time
        orDir := srcC > orOpen ? 1 : srcC < orOpen ? -1 : 0
        rvol := (not na(orVolAvg) and orVolAvg > 0) ? orVolAcc / orVolAvg : na
        inPlay := not useRvol or (not na(rvol) and rvol >= rvolMult)
        orVolAvg := na(orVolAvg) ? orVolAcc : orVolAvg + (orVolAcc - orVolAvg) * (2.0 / (rvolN + 1))
        orRng := orH - orL
        compRatio := (not na(orRngAvg) and orRngAvg > 0) ? orRng / orRngAvg : na
        orRngAvg := na(orRngAvg) ? orRng : orRngAvg + (orRng - orRngAvg) * (2.0 / (compN + 1))
        float mid = (orH + orL) / 2.0
        orBox := box.new(sesT0, orH, orEndT, orL, xloc = xloc.bar_time, border_color = color.new(colOR, 35), bgcolor = color.new(colOR, 88))
        orhG  := line.new(orEndT, orH, time, orH, xloc = xloc.bar_time, color = color.new(colOR, 80), width = lnWidth + 5)
        orhLn := line.new(orEndT, orH, time, orH, xloc = xloc.bar_time, color = color.new(colOR, 0), width = lnWidth)
        orlG  := line.new(orEndT, orL, time, orL, xloc = xloc.bar_time, color = color.new(colOR, 80), width = lnWidth + 5)
        orlLn := line.new(orEndT, orL, time, orL, xloc = xloc.bar_time, color = color.new(colOR, 0), width = lnWidth)
        midLn := line.new(orEndT, mid, time, mid, xloc = xloc.bar_time, color = color.new(colOR, 55), style = line.style_dotted, width = math.max(lnWidth - 1, 1))
        orhLb := label.new(time, orH, "ORH", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colOR, 0), textcolor = f_lum(colOR) > 140 ? color.rgb(10,10,10) : color.white, size = lvlSz)
        orlLb := label.new(time, orL, "ORL", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colOR, 0), textcolor = f_lum(colOR) > 140 ? color.rgb(10,10,10) : color.white, size = lvlSz)
        f_regBox(orBox)
        f_regLine(orhG)
        f_regLine(orhLn)
        f_regLine(orlG)
        f_regLine(orlLn)
        f_regLine(midLn)
        f_regLabel(orhLb)
        f_regLabel(orlLb)

    // extend the range lines across the developing session
    if orDone and not na(orhLn)
        line.set_x2(orhG, time)
        line.set_x2(orhLn, time)
        line.set_x2(orlG, time)
        line.set_x2(orlLn, time)
        line.set_x2(midLn, time)
        label.set_x(orhLb, time)
        label.set_x(orlLb, time)

    // detect the first accepted break (respecting the direction filter)
    // NOTE: target/stop are computed here for the win-rate harness and dashboard ONLY;
    // no target/stop/reversal lines are drawn on the chart in this build.
    if orDone and not broke and not na(orH) and not na(orL)
        bool upRaw = holdBar ? (srcC > orH and srcC[1] > orH) : srcC > orH
        bool dnRaw = holdBar ? (srcC < orL and srcC[1] < orL) : srcC < orL
        bool allowUp = biasMode == "Both ways" or orDir > 0
        bool allowDn = biasMode == "Both ways" or orDir < 0
        bool upBreak = upRaw and allowUp
        bool dnBreak = dnRaw and allowDn
        if upBreak or dnBreak
            broke := true
            brkDir := upBreak ? 1 : -1
            entryPx := srcC
            float rng = math.max(orH - orL, syminfo.mintick)
            float mid = (orH + orL) / 2.0
            stopPx := brkDir == 1 ? (stopMode == "Range midpoint" ? mid : stopMode == "ATR" ? entryPx - atrMultS * atrV : orL) : (stopMode == "Range midpoint" ? mid : stopMode == "ATR" ? entryPx + atrMultS * atrV : orH)
            float risk = math.max(math.abs(entryPx - stopPx), syminfo.mintick)
            if targetMode == "R multiple (risk)"
                t1 := brkDir == 1 ? entryPx + t1Mult * risk : entryPx - t1Mult * risk
                t2 := brkDir == 1 ? entryPx + t2Mult * risk : entryPx - t2Mult * risk
            else
                t1 := brkDir == 1 ? orH + t1Mult * rng : orL - t1Mult * rng
                t2 := brkDir == 1 ? orH + t2Mult * rng : orL - t2Mult * rng
            pend := true
            pendInPlay := inPlay

    // raw edge breaks (both sides) for trap / whipsaw detection
    if orDone
        if srcC > orH
            rawUp := true
        if srcC < orL
            rawDn := true
    // track the break's extreme (used as the failed-break reversal stop)
    if broke and brkDir == 1
        failExt := na(failExt) ? high : math.max(failExt, high)
    else if broke and brkDir == -1
        failExt := na(failExt) ? low : math.min(failExt, low)
    // retest-hold: a pullback to the broken edge that closes back beyond it = continuation confirm
    if showRetest and broke and not retestHeld and not failFlagged
        if brkDir == 1 and srcL <= orH and srcC > orH
            retestHeld := true
        else if brkDir == -1 and srcH >= orL and srcC < orL
            retestHeld := true
    // failed break: an accepted break closes back inside the range (fakeout -> reversal)
    // revTgt/revStop feed the fade harness and dashboard ONLY; the reversal line is not drawn.
    if showFade and broke and not failFlagged
        bool failedLong  = brkDir == 1 and srcC < orH
        bool failedShort = brkDir == -1 and srcC > orL
        if failedLong or failedShort
            failFlagged := true
            revDir := brkDir == 1 ? -1 : 1
            revTgt := brkDir == 1 ? orL : orH
            revStop := failExt
            revPend := true
            revN += 1
    // failed-break reversal harness: reach opposite edge before re-breaking the failure extreme
    if revPend and not na(revTgt) and not na(revStop)
        if revDir == -1
            if srcL <= revTgt
                revHit += 1
                revPend := false
            else if srcH >= revStop
                revPend := false
        else
            if srcH >= revTgt
                revHit += 1
                revPend := false
            else if srcL <= revStop
                revPend := false

    // path-aware win/loss tally: target 1 before stop (in-play gated)
    if pend and not na(t1) and not na(stopPx)
        bool countIt = not onlyInPlay or pendInPlay
        if brkDir == 1
            if srcH >= t1
                if countIt
                    winN += 1
                pend := false
            else if srcL <= stopPx
                if countIt
                    lossN += 1
                pend := false
        else if brkDir == -1
            if srcL <= t1
                if countIt
                    winN += 1
                pend := false
            else if srcH >= stopPx
                if countIt
                    lossN += 1
                pend := false

int resolved = winN + lossN
float hitP = calibOn and resolved > 0 ? winN * 100.0 / resolved : na
float edge = na(hitP) ? na : hitP - 50.0
float orRange = (na(orH) or na(orL)) ? na : orH - orL
float rr = (not na(t1) and not na(entryPx) and not na(stopPx) and math.abs(entryPx - stopPx) > 0) ? math.abs(t1 - entryPx) / math.abs(entryPx - stopPx) : na
string state = not orDone ? "forming" : not broke ? "no break" : brkDir == 1 ? "long break" : "short break"
float revHitP = showFade and revN >= 10 ? revHit * 100.0 / revN : na
float revEdge = na(revHitP) ? na : revHitP - 50.0
bool trap = rawUp and rawDn
string compTxt = na(compRatio) ? "warming" : compRatio < 0.8 ? "compressed" : compRatio > 1.3 ? "wide" : "normal"

// ── liquidity sweeps of the key levels (wick beyond, then close back inside) ──────────────
f_swHi(float L) => not na(L) and not na(atrV) and (high - L) >= liqWick * atrV and srcC < L
f_swLo(float L) => not na(L) and not na(atrV) and (L - low) >= liqWick * atrV and srcC > L
bool swPDH = showLiq and f_swHi(prevDayHi)
bool swPWH = showLiq and f_swHi(pwhRaw)
bool swPDL = showLiq and f_swLo(prevDayLo)
bool swPWL = showLiq and f_swLo(pwlRaw)
bool sweepNow = swPDH or swPWH or swPDL or swPWL
if sweepNow
    sweepDir := (swPDH or swPWH) ? -1 : 1
    sweepLvl := swPWH ? "PWH" : swPDH ? "PDH" : swPWL ? "PWL" : "PDL"
    sweepBar := bar_index
string dayPos = (na(prevDayHi) or na(prevDayLo)) ? "-" : srcC > prevDayHi ? "above PDH" : srcC < prevDayLo ? "below PDL" : "inside PD range"

// ── day / week reference levels with glowing lines and bold right-edge chips ─────────────
f_upd(line g, line c, label lb, float v) =>
    if not na(c) and not na(v) and not na(sesT0)
        line.set_xy1(g, sesT0, v)
        line.set_xy2(g, time, v)
        line.set_xy1(c, sesT0, v)
        line.set_xy2(c, time, v)
        label.set_xy(lb, time + 6 * barMs, v)
f_chip(color col) => f_lum(col) > 140 ? color.rgb(10, 10, 10) : color.white
var bool refsInit = false
if showLevels and not refsInit and not na(curDayHi) and not na(sesT0)
    gDH   := line.new(sesT0, curDayHi, time, curDayHi, xloc = xloc.bar_time, color = color.new(colDay, 82), width = lnWidth + 5, extend = extend.right)
    lnDH  := line.new(sesT0, curDayHi, time, curDayHi, xloc = xloc.bar_time, color = color.new(colDay, 20), width = lnWidth, extend = extend.right)
    gDL   := line.new(sesT0, curDayLo, time, curDayLo, xloc = xloc.bar_time, color = color.new(colDay, 82), width = lnWidth + 5, extend = extend.right)
    lnDL  := line.new(sesT0, curDayLo, time, curDayLo, xloc = xloc.bar_time, color = color.new(colDay, 20), width = lnWidth, extend = extend.right)
    gPDH  := line.new(sesT0, na(prevDayHi) ? curDayHi : prevDayHi, time, na(prevDayHi) ? curDayHi : prevDayHi, xloc = xloc.bar_time, color = color.new(colPDay, 82), width = lnWidth + 5, extend = extend.right)
    lnPDH := line.new(sesT0, na(prevDayHi) ? curDayHi : prevDayHi, time, na(prevDayHi) ? curDayHi : prevDayHi, xloc = xloc.bar_time, color = color.new(colPDay, 5), width = lnWidth, style = line.style_dashed, extend = extend.right)
    gPDL  := line.new(sesT0, na(prevDayLo) ? curDayLo : prevDayLo, time, na(prevDayLo) ? curDayLo : prevDayLo, xloc = xloc.bar_time, color = color.new(colPDay, 82), width = lnWidth + 5, extend = extend.right)
    lnPDL := line.new(sesT0, na(prevDayLo) ? curDayLo : prevDayLo, time, na(prevDayLo) ? curDayLo : prevDayLo, xloc = xloc.bar_time, color = color.new(colPDay, 5), width = lnWidth, style = line.style_dashed, extend = extend.right)
    gPWH  := line.new(sesT0, na(pwhRaw) ? curDayHi : pwhRaw, time, na(pwhRaw) ? curDayHi : pwhRaw, xloc = xloc.bar_time, color = color.new(colPWk, 82), width = lnWidth + 5, extend = extend.right)
    lnPWH := line.new(sesT0, na(pwhRaw) ? curDayHi : pwhRaw, time, na(pwhRaw) ? curDayHi : pwhRaw, xloc = xloc.bar_time, color = color.new(colPWk, 0), width = lnWidth, extend = extend.right)
    gPWL  := line.new(sesT0, na(pwlRaw) ? curDayLo : pwlRaw, time, na(pwlRaw) ? curDayLo : pwlRaw, xloc = xloc.bar_time, color = color.new(colPWk, 82), width = lnWidth + 5, extend = extend.right)
    lnPWL := line.new(sesT0, na(pwlRaw) ? curDayLo : pwlRaw, time, na(pwlRaw) ? curDayLo : pwlRaw, xloc = xloc.bar_time, color = color.new(colPWk, 0), width = lnWidth, extend = extend.right)
    lbDH  := label.new(time, curDayHi, "DH", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colDay, 0), textcolor = f_chip(colDay), size = lvlSz)
    lbDL  := label.new(time, curDayLo, "DL", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colDay, 0), textcolor = f_chip(colDay), size = lvlSz)
    lbPDH := label.new(time, curDayHi, "PDH", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colPDay, 0), textcolor = f_chip(colPDay), size = lvlSz)
    lbPDL := label.new(time, curDayLo, "PDL", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colPDay, 0), textcolor = f_chip(colPDay), size = lvlSz)
    lbPWH := label.new(time, curDayHi, "PWH", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colPWk, 0), textcolor = f_chip(colPWk), size = lvlSz)
    lbPWL := label.new(time, curDayLo, "PWL", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(colPWk, 0), textcolor = f_chip(colPWk), size = lvlSz)
    refsInit := true
if showLevels and refsInit
    f_upd(gDH, lnDH, lbDH, curDayHi)
    f_upd(gDL, lnDL, lbDL, curDayLo)
    f_upd(gPDH, lnPDH, lbPDH, prevDayHi)
    f_upd(gPDL, lnPDL, lbPDL, prevDayLo)
    f_upd(gPWH, lnPWH, lbPWH, pwhRaw)
    f_upd(gPWL, lnPWL, lbPWL, pwlRaw)

// ── clean, bar-anchored event markers (no stacking labels) ────────────────────────────────
bool brkUpNow  = broke and brkDir == 1 and not broke[1]
bool brkDnNow  = broke and brkDir == -1 and not broke[1]
bool failNow   = failFlagged and not failFlagged[1]
bool retestNow = retestHeld and not retestHeld[1]
bool trapNow   = trap and not trap[1]
plotshape(brkUpNow, "Long break", shape.triangleup, location.belowbar, color.new(colUp, 0), size = size.tiny)
plotshape(brkDnNow, "Short break", shape.triangledown, location.abovebar, color.new(colDn, 0), size = size.tiny)
plotshape(failNow and brkDir == 1, "Failed long", shape.xcross, location.abovebar, color.new(colFade, 0), size = size.tiny)
plotshape(failNow and brkDir == -1, "Failed short", shape.xcross, location.belowbar, color.new(colFade, 0), size = size.tiny)
plotshape(retestNow, "Retest hold", shape.circle, location.belowbar, color.new(colTgt, 0), size = size.tiny)
plotshape(sweepNow and sweepDir < 0, "Sweep (high)", shape.flag, location.abovebar, color.new(colPWk, 0), size = size.tiny)
plotshape(sweepNow and sweepDir > 0, "Sweep (low)", shape.flag, location.belowbar, color.new(colPWk, 0), size = size.tiny)
plot(brkDir, "→Conf: ORB", display=display.data_window)
// ═════════════════════════════════════════════════════════════════════════════════════════
//                              DASHBOARD  (theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cUp2    = darkUI ? colUp : color.rgb(14, 124, 90)
color cDn2    = darkUI ? colDn : color.rgb(198, 40, 40)

var table T = table.new(f_pos(panelPos), 2, 18, frame_width = 1, border_width = 1)
f_row(int rr2, string k, string v, color vc, color rbg) =>
    table.cell(T, 0, rr2, k, text_color = txtSub, text_size = size.tiny, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(T, 1, rr2, v, text_color = vc,     text_size = size.tiny, text_halign = text.align_right, bgcolor = rbg)

if showPanel and barstate.islast
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    color hdr = color.new(trap ? colFade : brkDir == 1 ? colUp : brkDir == -1 ? colDn : colOR, 0)
    string verdict = trap ? "TRAP DAY" : not orDone ? "FORMING" : not broke ? "NO BREAK" : failFlagged ? (brkDir == 1 ? "FAILED ▲" : "FAILED ▼") : brkDir == 1 ? "LONG BREAK" : "SHORT BREAK"
    table.cell(T, 0, 0, "ORB", text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(T, 1, 0, verdict, text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.tiny)
    f_row(1, "ORH / ORL", (na(orH) ? "-" : str.tostring(orH, format.mintick)) + " / " + (na(orL) ? "-" : str.tostring(orL, format.mintick)), txtMain, rowAlt)
    f_row(2, "Range", na(orRange) ? "-" : str.tostring(orRange, format.mintick), txtMain, panelBg)
    f_row(3, "Range state", compTxt, na(compRatio) ? txtMut : compRatio < 0.8 ? color.new(colTgt, 0) : compRatio > 1.3 ? cDn2 : txtMain, rowAlt)
    f_row(4, "Range dir", orDir > 0 ? "up" : orDir < 0 ? "down" : "flat", orDir > 0 ? cUp2 : orDir < 0 ? cDn2 : txtMut, panelBg)
    f_row(5, "Rel volume", na(rvol) ? "warming" : str.tostring(rvol, "0.0") + "x " + (inPlay ? "(in play)" : "(quiet)"), na(rvol) ? txtMut : inPlay ? cUp2 : txtMut, rowAlt)
    f_row(6, "State", state, brkDir == 1 ? cUp2 : brkDir == -1 ? cDn2 : txtMain, panelBg)
    f_row(7, "Target 1 / 2", (na(t1) ? "-" : str.tostring(t1, format.mintick)) + " / " + (na(t2) ? "-" : str.tostring(t2, format.mintick)), color.new(colTgt, 0), rowAlt)
    f_row(8, "Stop", na(stopPx) ? "-" : str.tostring(stopPx, format.mintick), cDn2, panelBg)
    f_row(9, "R:R (T1)", na(rr) ? "-" : str.tostring(rr, "0.0"), txtMain, rowAlt)
    f_row(10, "Day position", dayPos, dayPos == "above PDH" ? cUp2 : dayPos == "below PDL" ? cDn2 : txtMain, panelBg)
    f_row(11, "Liquidity", not showLiq ? "off" : sweepLvl != "" ? "swept " + sweepLvl + (sweepDir < 0 ? " (bear)" : " (bull)") : "-", sweepLvl != "" ? color.new(colPWk, 0) : txtMut, rowAlt)
    f_row(12, "Breaks (n)", str.tostring(resolved) + (timeoutN > 0 ? " (+" + str.tostring(timeoutN) + " eod)" : ""), txtMain, panelBg)
    f_row(13, "Hit % (T1 first)", resolved < 15 ? "warming" : str.tostring(hitP, "0") + "%", resolved < 15 ? txtMut : txtMain, rowAlt)
    f_row(14, "Edge", resolved < 15 or na(edge) ? "warming" : str.tostring(edge, "+0.0;-0.0") + " pts", (resolved < 15 or na(edge)) ? txtMut : edge > 3 ? cUp2 : edge < -3 ? cDn2 : txtMain, panelBg)
    f_row(15, "Failed break", not showFade ? "off" : failFlagged ? "fade to " + (na(revTgt) ? "-" : str.tostring(revTgt, format.mintick)) : "-", failFlagged ? color.new(colFade, 0) : txtMut, rowAlt)
    f_row(16, "Fade Hit %", not showFade ? "off" : revN < 10 ? "warming (" + str.tostring(revN) + ")" : str.tostring(revHitP, "0") + "% / " + str.tostring(revEdge, "+0;-0") + " (" + str.tostring(revN) + ")", (not showFade or revN < 10 or na(revEdge)) ? txtMut : revEdge > 5 ? cUp2 : revEdge < -5 ? cDn2 : txtMain, panelBg)
    f_row(17, "Retest / trap", trap ? "trap day" : retestHeld ? "retest held" : "-", trap ? color.new(colFade, 0) : retestHeld ? (brkDir == 1 ? cUp2 : cDn2) : txtMut, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          LEGEND KEY  (what every mark and line means)
// ═════════════════════════════════════════════════════════════════════════════════════════
var table K = table.new(f_pos(keyPos), 2, 9, frame_width = 1, border_width = 1)
f_key(int r, string sym, color sc, string meaning) =>
    table.cell(K, 0, r, sym, text_color = sc, text_size = size.tiny, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(K, 1, r, meaning, text_color = txtSub, text_size = size.tiny, text_halign = text.align_left, bgcolor = panelBg)
if showKey and barstate.islast
    table.set_bgcolor(K, panelBg)
    table.set_frame_color(K, frameC)
    table.set_border_color(K, frameC)
    table.cell(K, 0, 0, "KEY", text_color = txtMain, text_size = size.tiny, bgcolor = rowAlt)
    table.cell(K, 1, 0, "signal / line", text_color = txtSub, text_size = size.tiny, text_halign = text.align_left, bgcolor = rowAlt)
    f_key(1, "▲ ▼", cUp2, "Accepted break (long / short)")
    f_key(2, "✕",   color.new(colFade, 0), "Failed break  →  fade")
    f_key(3, "○",   color.new(colTgt, 0),  "Retest of edge held")
    f_key(4, "⚑",   color.new(colPWk, 0),  "Liquidity sweep of a level")
    f_key(5, "▬",   color.new(colOR, 0),   "Opening range  (ORH / ORL)")
    f_key(6, "▬",   color.new(colDay, 0),  "Day high / low  (DH / DL)")
    f_key(7, "▬",   color.new(colPDay, 0), "Prior day / week  (PD / PW)")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(brkUpNow, "Long break", "ORB: price accepted a break above the opening range")
alertcondition(brkDnNow, "Short break", "ORB: price accepted a break below the opening range")
alertcondition(failNow, "Failed break", "ORB: an accepted break failed back inside the range - reversal setup toward the opposite edge")
alertcondition(retestNow, "Retest hold", "ORB: the broken edge was retested and held - continuation confirmation")
alertcondition(trapNow, "Trap day", "ORB: both opening-range edges have broken - whipsaw / trap conditions")
alertcondition(sweepNow, "Liquidity sweep", "ORB: price swept a key day/week level and closed back inside - liquidity grab")
````

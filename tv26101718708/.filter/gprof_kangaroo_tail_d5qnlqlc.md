# GProf - Kangaroo Tail

- url: https://www.tradingview.com/script/D5QnLQlC-GProf-Kangaroo-Tail/
- type: indicator
- pine_id: PUB;bc2c89447744457581a5438cd2bd1adb
- version: 5.0

## Description

GProf - Kangaroo Tail
═══════════════════════════════════════════

OVERVIEW

This indicator detects a single, specific reversal event: a liquidity-sweep candle at a meaningful level — the Kangaroo Tail. Price runs an extreme, sweeps through a level where liquidity rests, and is rejected hard within one candle, closing back on the other side.

It is deliberately quiet. Most sessions it prints nothing. It speaks only when a candle sweeps a genuine multi-hour extreme, shows textbook rejection anatomy, and does so at a nameable level. The Kangaroo Tail is not a candle pattern that happens to be near a level — it is a level rejection whose evidence is a candle.

───────────────────────────────────────────
THE CANDLE (KT Short shown — KT Long is the mirror)

1. THE SWEEP — the candle's high prints a new high versus a long lookback (default 78 bars, about 6.5 hours on the 5m). Room to the left, measured in time: the extreme must be genuinely fresh, which excludes signals from inside congestion — you cannot sweep a multi-hour high from within chop.

2. REJECTION ANATOMY — the entire body sits in the bottom third of the range (body position is the filter; color is reported, not required). The opposite wick is capped tightly, and the sweep wick itself must be significant: at least a set percentage of the daily ATR, with a tick floor, so the threshold scales across instruments.

3. CONTEXT — the body sits inside the previous candle's range (toggleable), and a large prior same-direction candle raises a caution tag on the signal rather than suppressing it: the thrust into a level is often strong, and that thrust-sweep-reject sequence is the pattern at its best.

───────────────────────────────────────────
THE LEVEL — REQUIRED, AND MEASURED CORRECTLY

No level, no signal. The confluence set:

• Session levels: PMH/PML, YH/YL, PDC, WH/WL — computed internally, non-repainting.
• Camarilla pivots: R3/R4 for shorts, S3/S4 for longs, from yesterday's RTH high/low/close, DRAWN on the chart (S3/S4 green, R3/R4 red, central pivot marked).
• Up to three custom levels — enter your own higher-timeframe lines and they become part of the confluence set.

Two details most level tools get wrong:

LEVEL-IN-WICK GEOMETRY: the level must lie within the sweep wick's span. A deep sweep THROUGH the level is the pattern at its strongest, not a disqualification. When the wick spans more than one level, the nearest to the wick tip is named.

LIVE-LEVEL MATURITY: a running level (WH/WL always; PMH/PML while the premarket window is open) must rest untouched for a set number of bars before it counts — a sweep candle's own extreme IS the newborn premarket high, and a level seconds old is not structure.

WHEN "YESTERDAY" ROLLS: Roll Mode is Auto by default — futures roll at the 18:00 ET session open, equities at the next regular-session open — so evening and overnight signals test the session that just completed and the Camarilla levels derived from it. Session boundaries are read in exchange time, correct year-round through daylight-saving changes.

───────────────────────────────────────────
SIGNALS AND ALERTS

A qualifying candle prints one label — "KT ▼" or "KT ▲" — carrying its context: the level swept, whether the wick landed inside an unfilled qualified Fair Value Gap, and a caution tag when the prior candle was large.

The alert message includes everything needed to assess without opening the chart: sweep depth in points, the level, FVG confluence, body color, and reference trade geometry — trigger one tick beyond the KT extreme, stop one tick beyond the wick, and the 1:1 target.

Alert setup: add the indicator, create ONE alert with condition "Any alert() function call", expiration Open-ended. Direction is controlled in settings. Note: TradingView alerts snapshot settings at creation — after changing settings, recreate the alert.

A near-miss diagnostics mode (off by default) is available for investigation: candles at a level that fail exactly one anatomy check print a small marker naming it.

───────────────────────────────────────────
HOW TO USE IT

The Kangaroo Tail marks a completed liquidity event at structure. Traders who study these typically look for entry on a break of the candle's extreme in the rejection direction, with the stop beyond the sweep wick — the geometry the alert pre-computes. Keep your own higher-timeframe levels current in the custom slots: the level set is the heart of the tool.

This indicator identifies a candle pattern at a level. It does not generate buy/sell recommendations, does not place trades, and does not replace your own analysis and risk management.

───────────────────────────────────────────
TECHNICAL NOTES

• Non-repainting: all detection confirms on bar close; ATR uses completed daily bars; levels are built from session windows with no lookahead.
• Intraday timeframes only. Built for index and commodity futures but works on any liquid symbol; size thresholds are a percentage of daily ATR with tick floors, so they travel across instruments.
• Sweep lookback, anatomy thresholds, proximity band, maturity, and session times are fully configurable.

───────────────────────────────────────────
DISCLAIMER

This script is for informational and educational purposes only. It does not constitute financial, investment, or trading advice. A rejection candle at a level is a pattern, not a guarantee of future price behavior. All trading decisions made using this tool are solely the responsibility of the user.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GProfTrades
//@version=6
// ─────────────────────────────────────────────────────────────
//  GProf - Kangaroo Tail  v1.9.1
//  Single-candle liquidity-sweep reversal detector (KT strategy).
//
//  KT SHORT (mirror for LONG):
//   1. SWEEP: new high vs prior N bars (default 78).
//   2. BODY in the bottom 1/3 of range (color reported, not filtered).
//   3. OPPOSITE WICK <= max(25% of range, 1 tick).
//   4. SWEEP WICK >= max(1.5% of daily ATR, 8 ticks).
//   5. BODY inside previous candle's range (toggle, default ON).
//   6. PREVIOUS candle not a large same-direction candle (Warn Only).
//   7. LEVEL CONFLUENCE: the level must lie within the sweep wick's
//      span. Set: PMH/PML, YH/YL, PDC, WH/WL, YYH/YYL, Camarilla
//      R3/R4/R6 (short) and S3/S4/S6 (long), plus 3 custom levels.
//      Camarilla data source: Auto RTH/ETH (v1.9).
//  Confirmed on bar close. Non-repainting.
//
//  ---- CONDENSED HISTORY (full notes in PROJECT_HANDOFF.md) ----
//  v1.0  Anatomy + sweep; levels/FVG as tags only.
//  v1.1  Level confluence REQUIRED by default. 3 custom level inputs.
//        Near-miss diagnostics added.
//  v1.2  Diagnostics gated to fail-EXACTLY-ONE. Prior-momentum rule
//        demoted to Warn Only (it was killing thrust-into-level sweeps,
//        which are the core pattern).
//  v1.3  Level is a PREREQUISITE for any output: no level = no signal
//        AND no diagnostic. Sweep lookback 12 -> 40.
//  v1.4  Sweep lookback 40 -> 78 (~6.5h). LIVE-LEVEL MATURITY added.
//        Camarilla R3/R4/S3/S4 added to the confluence set.
//  v1.5  LEVEL-IN-WICK geometry replaces tip-proximity: a deep sweep
//        THROUGH a level is the pattern at its strongest.
//  v1.6  "Yesterday Rolls At" input, default 18:00 session open.
//  v1.7  DST-proof boundaries + Roll Mode Auto/Manual. Nearest-level-
//        wins labeling. Camarilla drawn on the chart.
//
//  v1.8 — FOUR CHANGES, all driven by live misses logged Sep 2026.
//
//   (1) OPPOSITE WICK CAP 5% -> 25% OF RANGE.
//       The 5% cap was rejecting textbook KTs across every instrument,
//       not just fine-tick ones. Measured live:
//         MNQ 10:35  range 41.50  opp wick  9.25  = 22.3%  WANTED
//         MNQ 07:15  range 27.25  opp wick  6.25  = 22.9%  WANTED
//         AMD 11:10  range  1.80  opp wick  0.38  = 21.1%  WANTED
//         MNQ 09:55  range 110.0  opp wick 31.75  = 28.9%  rejected
//       Three keeps cluster at 21-23% across three instruments and
//       three tick sizes; the one reject sits at 28.9%. 25% splits
//       them. Note the AMD case: 5% of a 1.80 range is 0.09, so a
//       0.38 wick — barely visible on screen — failed by 4x. This was
//       never an MCL tick-size problem; MCL only made it visible.
//       KNOWN COST: MCL Sep 2 (range 0.15, opp wick 0.03 = 20%) is
//       inside the keep cluster but was rejected by eye — the trader's
//       stated line there was 2 ticks. A single percentage cannot
//       reproduce that judgement. 25% is a starting value under live
//       observation, not a settled one.
//
//   (2) CAMARILLA R6 / S6 ADDED.
//       R6 = C x H / L. S6 = 2C - R6 — a REFLECTION of R6 about the
//       close, NOT the mirror C x L / H. Verified against a reference
//       implementation and reproduced numerically from MNQ Sep 9
//       (CP 29,525.50, H3 29,619.07 -> range 340.25 -> L4 29,338.36,
//       matching to the cent). R5/S5 deliberately NOT added.
//       Range source is unchanged: yesterday's RTH H/L, per the
//       existing engine. The reference implementation switches to full
//       ETH data when the overnight range exceeds RTH by >2% of ATR;
//       that is a larger change touching the shared level engine
//       (KT / LRA / B&R) and is NOT adopted here. [Superseded v1.9.]
//
//   (3) YYH / YYL — PREVIOUS OVERNIGHT (GLOBEX) EXTREMES.
//       The high and low of the completed 18:00-09:30 ET session,
//       frozen at 09:30 and held until the next 09:30. Distinct from
//       YH/YL (which are RTH by default) and from PMH/PML (today's
//       premarket, live until the open).
//       MGC Sep 2: a textbook KT swept to 4,445.5 — exactly the prior
//       overnight low — and was silent, because that level did not
//       exist anywhere in the tool. No level means no label AND no
//       diagnostic (v1.3), so the miss was invisible.
//       Toggleable; frozen once set, so maturity does not apply.
//
//   (4) EQUITIES: RTH ONLY.
//       For non-futures symbols, detection is suppressed outside the
//       market-hours window. Thin premarket and after-hours bars make
//       the anatomy percentages behave badly. Auto-detected from
//       syminfo.type, matching the Roll Mode precedent. Futures are
//       unaffected and continue to signal around the clock.
//
//   ALSO: GREEN/RED CLOSE CAUTION TAG. A short KT closing green (or a
//   long closing red) now appends ⚠grn / ⚠red to the label and alert,
//   following the ⚠mom pattern. Reported, never suppressed — body
//   POSITION remains the filter, body COLOUR remains information.
//   Two of the logged keeps closed against their direction and the
//   trades still worked; the journal decides whether it matters.
//
//   NOT CHANGED, and why:
//   * Opposite-wick tick FLOOR stays at 1 tick. At 25%, a candle needs
//     to be under 4 ticks of range before the floor binds at all.
//   * Body-zone boundary can still land between ticks and be
//     unreachable (MCL Sep 2: body top 91.38 vs a 91.3795 boundary,
//     failing by half a tick). Real, but it was the second failure on
//     that candle, not the deciding one. Open.
//   * A missing level still produces no diagnostic, which is what made
//     (3) invisible for weeks. Worth revisiting.
//  v1.8.1 — Publication chart updated. No functional change.
//
//  v1.9 — CAMARILLA ENGINE: AUTO RTH/ETH DATA. The v1.8 objection
//         (touching the shared engine) is avoided: the pivots get their
//         OWN accumulators; YH/YL/PDC, the suite roll rule, LRA and B&R
//         are untouched. Auto: if yesterday's post-market or today's
//         premarket (futures: from 18:00) extends yesterday's RTH
//         high/low by more than 2% of daily ATR, the pivots use the full
//         ETH day's H/L and the ETH close (last bar before the new
//         session); otherwise RTH H/L and the RTH close. Day boundary =
//         session first bar (futures 18:00, equities 4:00 premarket).
//         The premarket is watched LIVE, so pivots can step mid-session;
//         each bar is judged by the levels as they stood at that bar, so
//         history stays honest. MNQ Sep 25 01:05: overnight broke Sep
//         24's RTH high, pivots stepped to ETH (H4 30,986.71 / H3 30,861.11
//         / CP 30,735.50); AAPL Sep 24 ETH, Sep 25 RTH. R6/S6 computed
//         from the same H/L/C (S6 = 2C - R6, as in v1.8). Force
//         RTH / Force ETH and a separate Close override retained.
//         Equities need extended hours ON; an RTH-only chart falls back
//         to RTH. Drawn CP = the Camarilla close (can differ from PDC on
//         ETH days; PDC confluence unchanged). Debug label + Data Window
//         values added for verification.
//  v1.9.1 — DISPLAY ONLY. Camarilla (and YYH/YYL) lines now start at the
//         bar where the current level set began — the session start, or
//         the bar where Auto stepped to ETH — instead of the last bar.
//         Lines were landing off the right edge in Replay and in the
//         publication image (AMZN Sep 25: the 10:15 KT at S3 and the S3
//         line never shared a frame). Detection, levels, alerts unchanged.
// ─────────────────────────────────────────────────────────────
indicator("GProf - Kangaroo Tail", "GProf KT", overlay = true, max_labels_count = 400, max_boxes_count = 200)

// ── Inputs ───────────────────────────────────────────────────
grpK = "Kangaroo Tail Candle"
sweepN   = input.int(78,   "Sweep Lookback (bars)",         minval = 3, maxval = 300, group = grpK,
     tooltip = "The KT wick must print a new extreme versus this many prior bars — room to the left measured in time. 78 bars = ~6.5 hours on the 5m: the extreme must be untouched for most of a session.")
bodyFrac = input.float(33.0, "Body Zone (% of range)",      minval = 10.0, maxval = 50.0, step = 1.0, group = grpK)
oppWickPct = input.float(25.0, "Max Opposite Wick (% of range)", minval = 0.0, maxval = 50.0, step = 0.5, group = grpK,
     tooltip = "Applied as max(this % of range, 1 tick). RAISED FROM 5% IN v1.8. Live measurement: wanted KTs sat at 21-23% of range on MNQ, AMD and MCL alike; a rejected one sat at 28.9%. The old 5% cap rejected a 0.38 wick on a 1.80-range AMD candle — barely visible on screen. The ideal KT still has NO opposite wick at all; this is the outer tolerance, not the target.")
wickPct  = input.float(1.5,  "Min Sweep Wick (% of Daily ATR)", minval = 0.1, step = 0.1, group = grpK)
wickFlr  = input.int(8,    "Min Sweep Wick Floor (ticks)",  minval = 0, group = grpK)
reqInside = input.bool(true, "Require Body Inside Previous Candle", group = grpK)
momPct   = input.float(2.5,  "Max Prior Same-Direction Body (% of Daily ATR)", minval = 0.1, step = 0.1, group = grpK,
     tooltip = "TradeBook rule: no large opposing-momentum candle immediately before the KT.")
momFlr   = input.int(12,   "Prior Body Floor (ticks)",      minval = 0, group = grpK)
momMode  = input.string("Warn Only", "Prior-Momentum Rule", options = ["Hard Filter", "Warn Only"], group = grpK,
     tooltip = "Warn Only (default): signal fires with a ⚠mom tag. Hard Filter: signal suppressed. The thrust INTO a level often trips this, and that thrust-sweep-reject sequence IS the core pattern.")
warnClose = input.bool(true, "Tag Against-Direction Close (⚠grn / ⚠red)", group = grpK,
     tooltip = "A short KT that closes GREEN gets ⚠grn; a long KT that closes RED gets ⚠red. Reported, never suppressed — body POSITION is the filter, body COLOUR is information. Logged keeps have closed against direction and still worked.")
atrLenIn = input.int(14,   "ATR Length (days)",             minval = 1, group = grpK)

grpT = "Level Confluence"
lvlMode  = input.string("Require", "Level Confluence Mode", options = ["Require", "Tag Only"], group = grpT,
     tooltip = "Require: the KT wick must sit at a level to signal. Tag Only: every anatomical KT signals; levels are tagged when present.")
lvlPct   = input.float(0.5,  "Level Proximity (% of Daily ATR)", minval = 0.05, step = 0.05, group = grpT)
lvlFlr   = input.int(8,    "Level Proximity Floor (ticks)", minval = 0, group = grpT)
en_cam   = input.bool(true, "Camarilla R3/R4/R6 (shorts) · S3/S4/S6 (longs)", group = grpT,
     tooltip = "R3 = C + range x 1.1/4, R4 = C + range x 1.1/2, R6 = C x H / L. S3/S4 mirrored; S6 = 2C - R6, a reflection of R6 about the close (NOT C x L / H). Which day's H/L/C feeds them is set by Camarilla Data below.")
camSrc   = input.string("Auto", "Camarilla Data", options = ["Auto", "Force RTH", "Force ETH"], group = grpT,
     tooltip = "Auto: yesterday's RTH H/L unless yesterday's post-market or today's premarket (futures: from 18:00) extended beyond it by more than the tolerance below — then the full ETH day. The premarket is watched live, so pivots can step during the session. Equities need extended hours ON.")
camCls   = input.string("Auto", "Camarilla Close", options = ["Auto", "Force RTH", "Force ETH"], group = grpT,
     tooltip = "Auto: RTH close with RTH data, ETH close (last bar before the new session) with ETH data. Force either one regardless of the data in use.")
camTol   = input.float(2.0, "ETH Switching Tolerance (% of Daily ATR)", minval = 0.0, step = 0.1, group = grpT,
     tooltip = "How far outside yesterday's RTH range the post-market or premarket must trade before Auto switches to ETH data. Default: 2.")
en_yy    = input.bool(true, "YYH / YYL (prior overnight extremes)", group = grpT,
     tooltip = "The high and low of the last COMPLETED overnight session (18:00-09:30 ET), frozen at 09:30 and held until the next 09:30. Distinct from YH/YL (RTH by default) and from PMH/PML (today's premarket, live until the open). MGC Sep 2 swept exactly this level and was silent because it did not exist in the tool.")
matureB  = input.int(48,   "Live Level Maturity (bars)",    minval = 0, maxval = 500, group = grpT,
     tooltip = "A LIVE level (WH/WL always; PMH/PML while the premarket window is open) must be untouched this many bars before it counts. Frozen levels — including YYH/YYL — are exempt.")
cust1    = input.float(0.0, "Custom Level 1 (0 = off)", group = grpT,
     tooltip = "Your hand-drawn HTF levels, made machine-visible. Tagged 'HTF'.")
cust2    = input.float(0.0, "Custom Level 2 (0 = off)", group = grpT)
cust3    = input.float(0.0, "Custom Level 3 (0 = off)", group = grpT)
fvgPct   = input.float(2.0,  "Qualified FVG Min Size (% of Daily ATR)", minval = 0.1, step = 0.05, group = grpT)
fvgTicks = input.int(10,   "Qualified FVG Floor (ticks)",   minval = 0, group = grpT)
drawCam  = input.bool(true, "Draw Camarilla Levels", group = grpT)
drawYY   = input.bool(false, "Draw YYH / YYL", group = grpT)

grpD = "Diagnostics"
showDiag = input.bool(false, "Show Near-Miss Diagnostics", group = grpD,
     tooltip = "OFF by default. Turn ON only when investigating why an expected KT didn't print: at-level candles failing EXACTLY ONE check get a tiny gray 'KT?' marker naming it. NOTE: a candle with NO level at its wick produces no marker at all — if nothing prints, the level may be the reason.")
camDbg   = input.bool(false, "Camarilla Debug Label", group = grpD,
     tooltip = "Verification aid: prints the Camarilla engine's inputs and verdict on the last bar (mode, RTH/ETH/post/pre H-L-C, tolerance, levels). Cam values are also in the Data Window for bar-by-bar comparison.")

grpL = "Levels"
yest_rth = input.bool(true, "Yesterday RTH Only (9:30-16:00 ET)", group = grpL)
rollMode = input.string("Auto", "Roll Mode", options = ["Auto", "Manual"], group = grpL,
     tooltip = "Auto (default): futures roll yesterday at the 18:00 ET session open; equities/other at the next RTH open.")
rollOpt  = input.string("18:00 Session Open", "Yesterday Rolls At (Manual)", options = ["18:00 Session Open", "Next RTH Open"], group = grpL,
     tooltip = "Only used when Roll Mode = Manual.")
pm_opt  = input.string("4:00am-9:30am ET", "Premarket Session",
     options = ["4:00am-9:30am ET", "6:00pm-9:30am ET (Full Overnight)"], group = grpL)
mktHrs  = input.session("0930-1600", "Market Hours (RTH)", group = grpL)
tz      = input.string("America/New_York", "Time Zone",    group = grpL)
eqRTHonly = input.bool(true, "Equities: signal during RTH only", group = grpL,
     tooltip = "Non-futures symbols only, auto-detected from syminfo.type. Suppresses detection outside Market Hours: thin premarket and after-hours bars make the anatomy percentages behave badly. Futures are unaffected and signal around the clock.")

grpA = "Alerts"
alertMode = input.string("Both", "Alert Direction", options = ["Both", "Long Only", "Short Only", "Off"], group = grpA)

// ── Daily ATR ────────────────────────────────────────────────
atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atrLenIn)[1], lookahead = barmerge.lookahead_off)
wickMin = math.max(wickPct / 100.0 * atrDaily, wickFlr * syminfo.mintick)
momThr  = math.max(momPct  / 100.0 * atrDaily, momFlr * syminfo.mintick)
lvlProx = math.max(lvlPct  / 100.0 * atrDaily, lvlFlr * syminfo.mintick)
effFvg  = na(atrDaily) ? na : math.max(fvgPct / 100.0 * atrDaily, fvgTicks * syminfo.mintick)

// ── Session engine ───────────────────────────────────────────
pmSess  = pm_opt == "4:00am-9:30am ET" ? "0400-0930" : "1800-0930"
inRTH   = not na(time(timeframe.period, mktHrs, tz))
inPM    = not na(time(timeframe.period, pmSess, tz))
// The overnight / Globex window, always the full 18:00-09:30 regardless of
// the Premarket Session choice — YYH/YYL are defined on the Globex session,
// not on whichever premarket window the user prefers for PMH/PML.
inON    = not na(time(timeframe.period, "1800-0930", tz))
rthOpen = inRTH and not inRTH[1]
pmStart = inPM and not inPM[1]
onStart = inON and not inON[1]
onEnd   = not inON and inON[1]

bT       = time + 6 * 60 * 60 * 1000
sessDay  = dayofmonth(bT, "America/New_York") + month(bT, "America/New_York") * 100 + year(bT, "America/New_York") * 10000
sessWeek = weekofyear(bT, "America/New_York") + year(bT, "America/New_York") * 100
newDay   = ta.change(sessDay)  != 0
newWeek  = ta.change(sessWeek) != 0

bool isFutures = syminfo.type == "futures"

// ── Level accumulators ───────────────────────────────────────
var float tdHi = na, var float tdLo = na
var float yHi  = na, var float yLo  = na
var float pmHiAcc = na, var float pmLoAcc = na
var float pmHi = na, var float pmLo = na
var float lastRthClose = na, var float pdc = na
var float wkHi = na, var float wkLo = na
// YYH/YYL — prior completed overnight session
var float onHiAcc = na, var float onLoAcc = na
var float yyHi = na, var float yyLo = na

useNextOpen = rollMode == "Auto" ? (not isFutures) : (rollOpt == "Next RTH Open")
rollB = useNextOpen ? rthOpen : newDay
dayBoundary = yest_rth ? rollB : newDay
if dayBoundary
    yHi := tdHi, yLo := tdLo
    tdHi := na, tdLo := na
if rollB
    pdc := lastRthClose
if rthOpen
    pmHi := pmHiAcc, pmLo := pmLoAcc
if pmStart
    pmHiAcc := na, pmLoAcc := na
if yest_rth ? inRTH : true
    tdHi := na(tdHi) ? high : math.max(tdHi, high)
    tdLo := na(tdLo) ? low  : math.min(tdLo, low)
if inRTH
    lastRthClose := close
if inPM
    pmHiAcc := na(pmHiAcc) ? high : math.max(pmHiAcc, high)
    pmLoAcc := na(pmLoAcc) ? low  : math.min(pmLoAcc, low)
    pmHi := pmHiAcc, pmLo := pmLoAcc
if newWeek
    wkHi := na, wkLo := na
wkHi := na(wkHi) ? high : math.max(wkHi, high)
wkLo := na(wkLo) ? low  : math.min(wkLo, low)

// YYH/YYL: accumulate through the overnight window, FREEZE at 09:30 when it
// completes. The frozen pair then stands through the RTH day AND through the
// following night, so an evening KT tests the PREVIOUS night's extremes —
// not the one currently being built (which would be a self-reference, the
// same bug LIVE-LEVEL MATURITY exists to prevent for PMH/WH).
if onStart
    onHiAcc := na, onLoAcc := na
if inON
    onHiAcc := na(onHiAcc) ? high : math.max(onHiAcc, high)
    onLoAcc := na(onLoAcc) ? low  : math.min(onLoAcc, low)
if onEnd
    yyHi := onHiAcc, yyLo := onLoAcc

// ── Camarilla engine (v1.9 — Auto RTH/ETH data selection) ──
// Own accumulators, independent of YH/YL/PDC. Session markers:
//   futures:  RTH = Market Hours input; post starts at RTH end;
//             session first bar (18:00) = new ETH day + premarket start
//   equities: exchange sessions; premarket first bar (4:00) = new ETH day
cInRth     = isFutures ? inRTH : session.ismarket
cRegStart  = isFutures ? (inRTH and not inRTH[1]) : session.isfirstbar_regular
cPostStart = isFutures ? (inRTH[1] and not inRTH) : ((session.ispostmarket and session.ismarket[1]) or (session.isfirstbar and session.ismarket[1]))
cPreStart  = isFutures ? session.isfirstbar : ((session.ispremarket and session.isfirstbar) or (session.isfirstbar and session.isfirstbar_regular))
bsPre      = ta.barssince(cPreStart)
bsReg      = ta.barssince(cRegStart)
cInPre     = isFutures ? (bsPre < bsReg) : session.ispremarket

var float cRthHiAcc = na, var float cRthLoAcc = na, var float cLastRthC = na
var float pRthH = na, var float pRthL = na, var float pRthC = na      // RTH day captured at post start
var float yRthH = na, var float yRthL = na, var float yRthC = na      // active from the next session start
var float cEthHiAcc = na, var float cEthLoAcc = na
var float yEthH = na, var float yEthL = na, var float yEthC = na
var float cPostHiAcc = na, var float cPostLoAcc = na
var float yPostH = na, var float yPostL = na
var float cPreH = na, var float cPreL = na                            // today's premarket, live

// (a) RTH day completes at post start — held until the new session begins
if cPostStart
    pRthH := cRthHiAcc, pRthL := cRthLoAcc, pRthC := cLastRthC
// (b) new session: promote RTH, close out the ETH day and the post-market
if cPreStart
    yRthH := pRthH, yRthL := pRthL, yRthC := pRthC
    yEthH := cEthHiAcc, yEthL := cEthLoAcc, yEthC := close[1]
    yPostH := cPostHiAcc, yPostL := cPostLoAcc
    cEthHiAcc := na, cEthLoAcc := na
    cPreH := na, cPreL := na
// (c) resets after captures (RTH-only equity charts fire (a),(b),(c) on one bar)
if cPostStart
    cPostHiAcc := na, cPostLoAcc := na
if cRegStart
    cRthHiAcc := na, cRthLoAcc := na
// (d) accumulate the current bar
cEthHiAcc  := na(cEthHiAcc)  ? high : math.max(cEthHiAcc, high)
cEthLoAcc  := na(cEthLoAcc)  ? low  : math.min(cEthLoAcc, low)
cPostHiAcc := na(cPostHiAcc) ? high : math.max(cPostHiAcc, high)
cPostLoAcc := na(cPostLoAcc) ? low  : math.min(cPostLoAcc, low)
if cInRth
    cRthHiAcc := na(cRthHiAcc) ? high : math.max(cRthHiAcc, high)
    cRthLoAcc := na(cRthLoAcc) ? low  : math.min(cRthLoAcc, low)
    cLastRthC := close
if cInPre
    cPreH := na(cPreH) ? high : math.max(cPreH, high)
    cPreL := na(cPreL) ? low  : math.min(cPreL, low)

// Auto switch: post-market or premarket extends yesterday's RTH range by > tolerance
camTolPts  = na(atrDaily) ? na : atrDaily * camTol / 100.0
camHiExt   = na(yRthH) ? na : math.max(yRthH, nz(yPostH, yRthH), nz(cPreH, yRthH)) - yRthH
camLoExt   = na(yRthL) ? na : yRthL - math.min(yRthL, nz(yPostL, yRthL), nz(cPreL, yRthL))
camAutoEth = not na(camTolPts) and not na(camHiExt) and not na(camLoExt) and (camHiExt > camTolPts or camLoExt > camTolPts)
camUseEth  = camSrc == "Force ETH" or (camSrc == "Auto" and camAutoEth)
camH  = camUseEth ? yEthH : yRthH
camL  = camUseEth ? yEthL : yRthL
camCP = camCls == "Force RTH" ? yRthC : camCls == "Force ETH" ? yEthC : (camUseEth ? yEthC : yRthC)

// ── Camarilla pivots (from the engine's H/L/C) ───────────────
// R3/R4/S3/S4: classic 1.1 multipliers.
// R6 = C x H / L.
// S6 = 2C - R6 — a REFLECTION of R6 about the close, not C x L / H.
//      The two differ materially; the reflection is the correct one.
camRng = not na(camH) and not na(camL) ? camH - camL : na
camR3  = not na(camRng) and not na(camCP) ? camCP + camRng * 1.1 / 4.0 : na
camR4  = not na(camRng) and not na(camCP) ? camCP + camRng * 1.1 / 2.0 : na
camS3  = not na(camRng) and not na(camCP) ? camCP - camRng * 1.1 / 4.0 : na
camS4  = not na(camRng) and not na(camCP) ? camCP - camRng * 1.1 / 2.0 : na
camR6  = not na(camH) and not na(camL) and not na(camCP) and camL != 0 ? camCP * camH / camL : na
camS6  = not na(camR6) and not na(camCP) ? 2.0 * camCP - camR6 : na

// ── Live-level maturity clocks ───────────────────────────────
var float pPmHi = na, var int chgPmHi = -9999
var float pPmLo = na, var int chgPmLo = -9999
var float pWkHi = na, var int chgWkHi = -9999
var float pWkLo = na, var int chgWkLo = -9999
if not na(pmHi) and (na(pPmHi) or pmHi != pPmHi)
    chgPmHi := bar_index
pPmHi := pmHi
if not na(pmLo) and (na(pPmLo) or pmLo != pPmLo)
    chgPmLo := bar_index
pPmLo := pmLo
if not na(wkHi) and (na(pWkHi) or wkHi != pWkHi)
    chgWkHi := bar_index
pWkHi := wkHi
if not na(wkLo) and (na(pWkLo) or wkLo != pWkLo)
    chgWkLo := bar_index
pWkLo := wkLo
pmHiOK = not inPM or bar_index - chgPmHi >= matureB
pmLoOK = not inPM or bar_index - chgPmLo >= matureB
wkHiOK = bar_index - chgWkHi >= matureB
wkLoOK = bar_index - chgWkLo >= matureB

// ── Qualified FVG zone tracking (for the "in FVG" tag) ───────
var array<box> bullZones = array.new<box>()
var array<box> bearZones = array.new<box>()

bullFVG  = low > high[2]
bearFVG  = high < low[2]
qualBull = bullFVG and not na(effFvg) and (low - high[2])  >= effFvg
qualBear = bearFVG and not na(effFvg) and (low[2] - high) >= effFvg

if barstate.isconfirmed
    if bullZones.size() > 0
        for i = bullZones.size() - 1 to 0
            b = bullZones.get(i)
            if low <= box.get_bottom(b)
                box.delete(b)
                bullZones.remove(i)
    if bearZones.size() > 0
        for i = bearZones.size() - 1 to 0
            b = bearZones.get(i)
            if high >= box.get_top(b)
                box.delete(b)
                bearZones.remove(i)
    if qualBull
        bullZones.push(box.new(bar_index - 2, low, bar_index, high[2], border_color = na, bgcolor = na))
        if bullZones.size() > 50
            box.delete(bullZones.shift())
    if qualBear
        bearZones.push(box.new(bar_index - 2, low[2], bar_index, high, border_color = na, bgcolor = na))
        if bearZones.size() > 50
            box.delete(bearZones.shift())

inZone(array<box> zones, float p) =>
    bool hit = false
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            b = zones.get(i)
            if p <= box.get_top(b) and p >= box.get_bottom(b)
                hit := true
                break
    hit

// ── Level confluence: NEAREST level within the sweep wick wins ─
inSpan(float L, float lo, float hi) =>
    not na(L) and L >= lo - lvlProx and L <= hi + lvlProx

consider(float L, bool ok, float tip, float lo, float hi, float bestD, string bestT, string thisT) =>
    float d = na
    string t = bestT
    float bd = bestD
    if not na(L) and ok and inSpan(L, lo, hi)
        d := math.abs(L - tip)
        if d < bestD
            bd := d
            t  := thisT
    [bd, t]

nearLevel(float lo, float hi, bool shortSide) =>
    float tip = shortSide ? hi : lo
    float bestD = 1e20
    string tag = ""
    if shortSide
        [d1, t1] = consider(pmHi, pmHiOK, tip, lo, hi, bestD, tag, "PMH")
        bestD := d1, tag := t1
        [d2, t2] = consider(yHi, true, tip, lo, hi, bestD, tag, "YH")
        bestD := d2, tag := t2
        [d3, t3] = consider(pdc, true, tip, lo, hi, bestD, tag, "PDC")
        bestD := d3, tag := t3
        [d4, t4] = consider(wkHi, wkHiOK, tip, lo, hi, bestD, tag, "WH")
        bestD := d4, tag := t4
        if en_yy
            [dy, ty] = consider(yyHi, true, tip, lo, hi, bestD, tag, "YYH")
            bestD := dy, tag := ty
        if en_cam
            [d5, t5] = consider(camR3, true, tip, lo, hi, bestD, tag, "R3")
            bestD := d5, tag := t5
            [d6, t6] = consider(camR4, true, tip, lo, hi, bestD, tag, "R4")
            bestD := d6, tag := t6
            [d7, t7] = consider(camR6, true, tip, lo, hi, bestD, tag, "R6")
            bestD := d7, tag := t7
    else
        [d1, t1] = consider(pmLo, pmLoOK, tip, lo, hi, bestD, tag, "PML")
        bestD := d1, tag := t1
        [d2, t2] = consider(yLo, true, tip, lo, hi, bestD, tag, "YL")
        bestD := d2, tag := t2
        [d3, t3] = consider(pdc, true, tip, lo, hi, bestD, tag, "PDC")
        bestD := d3, tag := t3
        [d4, t4] = consider(wkLo, wkLoOK, tip, lo, hi, bestD, tag, "WL")
        bestD := d4, tag := t4
        if en_yy
            [dy, ty] = consider(yyLo, true, tip, lo, hi, bestD, tag, "YYL")
            bestD := dy, tag := ty
        if en_cam
            [d5, t5] = consider(camS3, true, tip, lo, hi, bestD, tag, "S3")
            bestD := d5, tag := t5
            [d6, t6] = consider(camS4, true, tip, lo, hi, bestD, tag, "S4")
            bestD := d6, tag := t6
            [d7, t7] = consider(camS6, true, tip, lo, hi, bestD, tag, "S6")
            bestD := d7, tag := t7
    [dc1, tc1] = consider(cust1 > 0 ? cust1 : na, true, tip, lo, hi, bestD, tag, "HTF")
    bestD := dc1, tag := tc1
    [dc2, tc2] = consider(cust2 > 0 ? cust2 : na, true, tip, lo, hi, bestD, tag, "HTF")
    bestD := dc2, tag := tc2
    [dc3, tc3] = consider(cust3 > 0 ? cust3 : na, true, tip, lo, hi, bestD, tag, "HTF")
    bestD := dc3, tag := tc3
    tag

// ── KT detection ─────────────────────────────────────────────
rng      = high - low
bodyTop  = math.max(open, close)
bodyBot  = math.min(open, close)
oppWickMax = math.max(oppWickPct / 100.0 * rng, syminfo.mintick)
sweptHigh = high > ta.highest(high, sweepN)[1]
sweptLow  = low  < ta.lowest(low, sweepN)[1]

// EQUITIES: RTH ONLY (v1.8). Futures signal around the clock.
bool rthOk = isFutures or not eqRTHonly or inRTH

diagMark(float y, bool below, string why) =>
    label.new(bar_index, y, "KT? " + why,
         style = below ? label.style_label_up : label.style_label_down,
         color = color.new(color.gray, 75), textcolor = color.silver, size = size.tiny)

if barstate.isconfirmed and timeframe.isintraday and not na(atrDaily) and rng > 0 and rthOk
    // ---- SHORT side — the LEVEL is a prerequisite: no level, no ink
    if sweptHigh
        lvlTag  = nearLevel(bodyTop, high, true)
        if lvlMode == "Tag Only" or lvlTag != ""
            cBody   = bodyTop <= low + bodyFrac / 100.0 * rng
            cOpp    = (bodyBot - low) <= oppWickMax
            cWick   = (high - bodyTop) >= wickMin
            cIns    = not reqInside or (bodyBot >= low[1] and bodyTop <= high[1])
            momTrip = close[1] > open[1] and (close[1] - open[1]) > momThr
            cMom    = momMode == "Warn Only" or not momTrip
            nFail   = (cBody ? 0 : 1) + (cOpp ? 0 : 1) + (cWick ? 0 : 1) + (cIns ? 0 : 1) + (cMom ? 0 : 1)
            if nFail == 0
                fvgTag = inZone(bearZones, high)
                grnTrip = warnClose and close >= open
                trig   = low - syminfo.mintick
                stopP  = high + syminfo.mintick
                tags   = (lvlTag != "" ? " @ " + lvlTag : "") + (fvgTag ? " · in FVG" : "") +
                     (momTrip ? " ⚠mom" : "") + (grnTrip ? " ⚠grn" : "")
                label.new(bar_index, high, "KT ▼" + tags,
                     style = label.style_label_down, color = color.new(color.red, 30),
                     textcolor = color.white, size = size.small)
                if alertMode == "Both" or alertMode == "Short Only"
                    alert("KT SHORT: " + syminfo.ticker + " " + timeframe.period + " — swept " + str.tostring(sweepN) +
                         "-bar high, wick " + str.tostring(high - bodyTop, "#.##") + " pts" +
                         (lvlTag != "" ? " @ " + lvlTag : "") + (fvgTag ? ", in qualified FVG" : "") +
                         (momTrip ? ", WARN: large prior candle" : "") +
                         (grnTrip ? ", WARN: green close" : "") +
                         " | body " + (close >= open ? "green" : "red") +
                         " | trigger " + str.tostring(trig, format.mintick) +
                         ", stop " + str.tostring(stopP, format.mintick) +
                         ", 1:1 " + str.tostring(trig - (stopP - trig), format.mintick), alert.freq_once_per_bar)
            else if showDiag and nFail == 1
                why = not cBody ? "body" : not cOpp ? "opp-wick" : not cWick ? "wick-size" :
                     not cIns ? "inside" : "prior-mom"
                diagMark(high, false, why)
    // ---- LONG side — the LEVEL is a prerequisite: no level, no ink
    if sweptLow
        lvlTag  = nearLevel(low, bodyBot, false)
        if lvlMode == "Tag Only" or lvlTag != ""
            cBody   = bodyBot >= high - bodyFrac / 100.0 * rng
            cOpp    = (high - bodyTop) <= oppWickMax
            cWick   = (bodyBot - low) >= wickMin
            cIns    = not reqInside or (bodyBot >= low[1] and bodyTop <= high[1])
            momTrip = close[1] < open[1] and (open[1] - close[1]) > momThr
            cMom    = momMode == "Warn Only" or not momTrip
            nFail   = (cBody ? 0 : 1) + (cOpp ? 0 : 1) + (cWick ? 0 : 1) + (cIns ? 0 : 1) + (cMom ? 0 : 1)
            if nFail == 0
                fvgTag = inZone(bullZones, low)
                redTrip = warnClose and close <= open
                trig   = high + syminfo.mintick
                stopP  = low - syminfo.mintick
                tags   = (lvlTag != "" ? " @ " + lvlTag : "") + (fvgTag ? " · in FVG" : "") +
                     (momTrip ? " ⚠mom" : "") + (redTrip ? " ⚠red" : "")
                label.new(bar_index, low, "KT ▲" + tags,
                     style = label.style_label_up, color = color.new(color.teal, 30),
                     textcolor = color.white, size = size.small)
                if alertMode == "Both" or alertMode == "Long Only"
                    alert("KT LONG: " + syminfo.ticker + " " + timeframe.period + " — swept " + str.tostring(sweepN) +
                         "-bar low, wick " + str.tostring(bodyBot - low, "#.##") + " pts" +
                         (lvlTag != "" ? " @ " + lvlTag : "") + (fvgTag ? ", in qualified FVG" : "") +
                         (momTrip ? ", WARN: large prior candle" : "") +
                         (redTrip ? ", WARN: red close" : "") +
                         " | body " + (close >= open ? "green" : "red") +
                         " | trigger " + str.tostring(trig, format.mintick) +
                         ", stop " + str.tostring(stopP, format.mintick) +
                         ", 1:1 " + str.tostring(trig + (trig - stopP), format.mintick), alert.freq_once_per_bar)
            else if showDiag and nFail == 1
                why = not cBody ? "body" : not cOpp ? "opp-wick" : not cWick ? "wick-size" :
                     not cIns ? "inside" : "prior-mom"
                diagMark(low, true, why)

// ── Line start bars (v1.9.1): where the current level set began ─
var int camStart = na
var int yyStart  = na
camChg = nz(camR3) != nz(camR3[1]) or nz(camS3) != nz(camS3[1]) or nz(camCP) != nz(camCP[1]) or nz(camR6) != nz(camR6[1])
if camChg or na(camStart)
    camStart := bar_index
yyChg = nz(yyHi) != nz(yyHi[1]) or nz(yyLo) != nz(yyLo[1])
if yyChg or na(yyStart)
    yyStart := bar_index

// ── Draw levels ──────────────────────────────────────────────
var line lnR3 = na, var line lnR4 = na, var line lnR6 = na
var line lnS3 = na, var line lnS4 = na, var line lnS6 = na, var line lnCP = na
var line lnYYH = na, var line lnYYL = na
var label lbR3 = na, var label lbR4 = na, var label lbR6 = na
var label lbS3 = na, var label lbS4 = na, var label lbS6 = na, var label lbCP = na
var label lbYYH = na, var label lbYYL = na
drawLvl(line ln, label lb, float v, color c, string txt, int x1) =>
    line  outLn = ln
    label outLb = lb
    if not na(v)
        if na(outLn)
            outLn := line.new(x1, v, bar_index + 1, v, color = c, style = line.style_solid, extend = extend.right)
            outLb := label.new(bar_index + 1, v, txt, style = label.style_none, textcolor = c, size = size.small)
        else
            outLn.set_y1(v), outLn.set_y2(v), outLn.set_x1(x1), outLn.set_x2(bar_index + 1)
            outLb.set_xy(bar_index + 1, v), outLb.set_text(txt)
    [outLn, outLb]
if drawCam and en_cam and barstate.islast
    [a0, b0] = drawLvl(lnR6, lbR6, camR6, color.new(color.red, 0),  "R6", camStart), lnR6 := a0, lbR6 := b0
    [a1, b1] = drawLvl(lnR4, lbR4, camR4, color.new(color.red, 0),  "R4", camStart), lnR4 := a1, lbR4 := b1
    [a2, b2] = drawLvl(lnR3, lbR3, camR3, color.new(color.red, 0),  "R3", camStart), lnR3 := a2, lbR3 := b2
    [a3, b3] = drawLvl(lnCP, lbCP, camCP, color.new(color.blue, 0), "CP", camStart), lnCP := a3, lbCP := b3
    [a4, b4] = drawLvl(lnS3, lbS3, camS3, color.new(color.green, 0),"S3", camStart), lnS3 := a4, lbS3 := b4
    [a5, b5] = drawLvl(lnS4, lbS4, camS4, color.new(color.green, 0),"S4", camStart), lnS4 := a5, lbS4 := b5
    [a6, b6] = drawLvl(lnS6, lbS6, camS6, color.new(color.green, 0),"S6", camStart), lnS6 := a6, lbS6 := b6
if drawYY and en_yy and barstate.islast
    [c1, d1] = drawLvl(lnYYH, lbYYH, yyHi, color.new(color.orange, 0), "YYH", yyStart), lnYYH := c1, lbYYH := d1
    [c2, d2] = drawLvl(lnYYL, lbYYL, yyLo, color.new(color.orange, 0), "YYL", yyStart), lnYYL := c2, lbYYL := d2

// ── Camarilla verification (v1.9) — values in the Data Window ─
plot(camR6, "Cam R6", color.red,   display = display.data_window)
plot(camR4, "Cam R4", color.red,   display = display.data_window)
plot(camR3, "Cam R3", color.red,   display = display.data_window)
plot(camCP, "Cam CP", color.blue,  display = display.data_window)
plot(camS3, "Cam S3", color.green, display = display.data_window)
plot(camS4, "Cam S4", color.green, display = display.data_window)
plot(camS6, "Cam S6", color.green, display = display.data_window)
plot(camUseEth ? 1 : 0, "Cam ETH (1) / RTH (0)", color.gray, display = display.data_window)

fmtCam(float v) => na(v) ? "na" : str.tostring(v, format.mintick)
var label camDbgLbl = na
if camDbg and barstate.islast
    label.delete(camDbgLbl)
    txt = "CAM " + (camUseEth ? "ETH" : "RTH") + " (" + camSrc + ", close " + camCls + ")" +
         "\nRTH  H " + fmtCam(yRthH) + "  L " + fmtCam(yRthL) + "  C " + fmtCam(yRthC) +
         "\nETH  H " + fmtCam(yEthH) + "  L " + fmtCam(yEthL) + "  C " + fmtCam(yEthC) +
         "\nPost H " + fmtCam(yPostH) + "  L " + fmtCam(yPostL) +
         "\nPre  H " + fmtCam(cPreH) + "  L " + fmtCam(cPreL) + (cInPre ? "  (live)" : "") +
         "\nExt  hi " + fmtCam(camHiExt) + "  lo " + fmtCam(camLoExt) + "  tol " + fmtCam(camTolPts) +
         "\nR6 " + fmtCam(camR6) + "  R4 " + fmtCam(camR4) + "  R3 " + fmtCam(camR3) + "  CP " + fmtCam(camCP) +
         "\nS3 " + fmtCam(camS3) + "  S4 " + fmtCam(camS4) + "  S6 " + fmtCam(camS6)
    camDbgLbl := label.new(bar_index + 3, close, txt, style = label.style_label_left,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small, textalign = text.align_left)
````

# GProf - Levels, RVOL, ATR

- url: https://www.tradingview.com/script/91RjvxFG-GProf-Levels-RVOL-ATR/
- type: indicator
- pine_id: PUB;92408dc6495649248c0c4e18a06f21e1
- version: 2.0

## Description

GProf - Levels, RVOL, ATR
═══════════════════════════════════════════

OVERVIEW

This indicator answers the three questions an intraday trader asks before and during every session, in one tool:

1. LOCATION — Where is price relative to the structure that matters?
2. PARTICIPATION — Who showed up today, compared to a normal day?
3. RANGE — How much movement is statistically normal, and how much has already been spent?

It combines key session levels, time-of-day Relative Volume (RVOL), and a 14-day ATR with a live Range/ATR reading, shown as clean level lines plus a compact on-chart dashboard. Built with index and commodity futures in mind (NQ, ES, YM, RTY, GC, CL and their micros), it works on any intraday symbol with volume data, and adapts its session logic automatically between futures and equities.

───────────────────────────────────────────
LAYER 1: LOCATION — SESSION LEVELS

• YH / YL — Yesterday's High and Low, RTH-only or full session day.
• PDC — Previous Day Close.
• PMH / PML — Premarket High and Low (4:00am–9:30am ET, or the full overnight session to capture the entire Globex range on futures). Live during the premarket, then frozen at the open.
• WH / WL — The current week's running High and Low, updating in real time.

Each level is a labeled horizontal line with a matching price-scale marker. Colors, width, and labels are configurable, and each group toggles independently.

WHEN "YESTERDAY" ROLLS: by default, Roll Mode is Auto — futures roll yesterday's levels at the 18:00 ET session open (the exchange's own trading-day boundary, so evening and overnight sessions reference the day that just completed), while equities and other symbols roll at the next regular-session open. A manual override is available. Session-day and week boundaries are read in exchange time, so they are correct year-round through daylight-saving changes and hold up across holiday-shortened weeks.

───────────────────────────────────────────
LAYER 2: PARTICIPATION — RVOL

Raw volume comparisons mislead: the first 30 minutes of a session always dwarf lunch hour. This RVOL is time-of-day aware. It records the cumulative session-volume profile for each of the last N sessions, then compares today's cumulative volume to the average at the same elapsed minute of the session.

A reading of 100% means participation is exactly normal for this time of day; 150% means today is running half again above normal. The dashboard colors the reading against a configurable threshold. RVOL is a regular-session metric and reads N/A outside those hours.

───────────────────────────────────────────
LAYER 3: RANGE — ATR(14) AND RANGE/ATR

The dashboard shows the daily ATR (default 14 days), calculated from completed daily bars only — stable all day, never repainting intraday.

More useful than the raw number is Range/ATR: today's range so far as a percentage of the ATR. Under 70% (green), a statistically normal amount of range remains. Between 70–100% (orange), the day is approaching its average. Over 100% (red), the day has already exceeded a normal range, so late continuation attempts are fighting a mostly-spent tape.

Optional ATR Projection Bands (off by default) draw Today's Low + ATR and Today's High − ATR as live exhaustion estimates; when they invert, the day has exceeded its average range — visible at a glance.

───────────────────────────────────────────
HOW TO USE IT

Before the open: note where price sits relative to PMH/PML, YH/YL, and PDC. Confluence between these marks the zones most likely to produce reactions.

At the open: watch RVOL. An opening drive on 130%+ participation behaves very differently from one on 60%.

During the session: use Range/ATR as context for continuation versus exhaustion. A breakout attempt at 95% of ATR deserves more skepticism than the same pattern at 40%.

This indicator draws context only. It does not generate signals, place trades, or replace your own analysis and risk management.

───────────────────────────────────────────
TECHNICAL NOTES

• Non-repainting by design: no lookahead requests, no lower-timeframe data. Levels are built from chart-bar session windows; ATR uses completed daily bars; RVOL uses only accumulated history.
• Best on standard intraday timeframes (1m, 3m, 5m, 15m, 30m). Not intended for daily or higher charts.
• RVOL needs its lookback period of visible chart history to build a full profile; readings in the first sessions after loading are based on fewer samples.
• Session times, timezone, and roll behavior are fully configurable; defaults follow US equities/futures conventions.

───────────────────────────────────────────
DISCLAIMER

This script is for informational and educational purposes only. It does not constitute financial, investment, or trading advice. Past behavior of price, volume, or volatility does not guarantee future results. All trading decisions made using this tool are solely the responsibility of the user.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GProfTrades
//
// GProf - Levels, RVOL, ATR
// Version 4.4
// -----------------------------------------
// v1.0 — Initial Release: YH, YL, PMH, PML with session inputs
// v1.1 — Added Previous Day Close (PDC)
// v1.2 — Added RVOL Table (time-of-day volume profiling)
// v1.3 — Fixed Full 24hr Session YH/YL; RVOL timeframe independence
// v1.4 — Added Weekly High (WH) and Weekly Low (WL)
// v2.0 — Rewrite on borrowed engine (deprecated)
// v3.0 — Clean-room rewrite: session-window accumulators, no repainting
// v4.0 — Unified edition: Levels + RVOL + ATR(14d) + Range/ATR,
//        consolidated dashboard, optional ATR projection bands
// v4.1 — FIX: weekly/daily boundary detection. timeframe.change("W")
//        failed to fire across the July 2026 holiday weekend (stale WL
//        carried from prior week — masked on MNQ where price traded
//        through the old low, exposed on MES where it did not).
//        Boundaries are now derived directly from the calendar:
//        bar time shifted +6h so the CME 18:00 ET session open maps to
//        midnight, then day/week indices computed arithmetically.
//        NOTE: anchors boundaries to the CME futures session convention.
// v4.2 — "Yesterday Rolls At" input (default: 18:00 Session Open,
//        CME's own day boundary). YH/YL/PDC now roll at the Globex
//        open so evening/overnight trading references the session
//        that just closed, not the day before it (M2K Jul 22: a
//        valid evening setup at that day's RTH low was invisible
//        because YL still held the prior day). "Next RTH Open"
//        retained as the legacy option. Premarket freeze unchanged
//        at 9:30. With the 18:00 roll, Range/ATR reads N/A between
//        18:00 and the next RTH open — no RTH range exists yet.
// v4.3 — DST-proof boundaries: read the calendar in America/New_York
//        instead of shifting raw UTC (the shift made "18:00" fire at
//        2:00 PM ET under daylight saving — AAPL Jul: YH truncated
//        mid-session). Added Roll Mode = Auto (default) / Manual:
//        Auto detects instrument type (futures roll at 18:00, equities
//        at the next RTH open) so no setting changes when switching
//        between futures and stocks. Manual defers to the dropdown.
// v4.4 — CAMARILLA LEVELS (R3/R4/R6, CP, S3/S4/S6), toggleable, so the
//        full level set is available without loading Kangaroo Tail.
//        The engine is a line-for-line copy of KT v1.9.1: its own
//        accumulators (YH/YL/PDC and the roll rule untouched); Auto
//        RTH/ETH data — if yesterday's post-market or today's premarket
//        (futures: from 18:00) extends yesterday's RTH high/low by more
//        than 2% of daily ATR, pivots use the full ETH day's H/L and
//        the ETH close, otherwise RTH H/L and the RTH close. Lines start
//        where the current level set began (session start, or the bar
//        where Auto stepped to ETH). Dashboard shows the data in use.
//        STANDING RULE: any change to the Camarilla engine must be made
//        in KT and LRA together, or the two will draw different pivots.
// -----------------------------------------

//@version=6
indicator("GProf - Levels, RVOL, ATR", "GProf LRA", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─── SETTINGS ────────────────────────────────────────────────────────────────
// Location: structure levels
show_yest  = input.bool(true,     "Show Yesterday High/Low",     group = "Levels: Yesterday")
yh_color   = input.color(#00ff00, "Yesterday High Color",        group = "Levels: Yesterday")
yl_color   = input.color(#ff5050, "Yesterday Low Color",         group = "Levels: Yesterday")
yest_rth   = input.bool(true,     "RTH Only (9:30am-4:00pm ET)", group = "Levels: Yesterday",
     tooltip = "On: yesterday's high/low from RTH only. Off: full session day (18:00-17:00 ET for CME futures).")
rollMode   = input.string("Auto", "Roll Mode", options = ["Auto", "Manual"], group = "Levels: Yesterday",
     tooltip = "Auto (default): futures roll yesterday at the 18:00 ET session open (CME's day boundary); equities and other symbols roll at the next RTH open. Detected from the instrument type — no need to touch it when switching between futures and stocks. Manual: use the 'Yesterday Rolls At' setting below.")
rollOpt    = input.string("18:00 Session Open", "Yesterday Rolls At (Manual)", options = ["18:00 Session Open", "Next RTH Open"], group = "Levels: Yesterday",
     tooltip = "Only used when Roll Mode = Manual. 18:00 Session Open: CME's day boundary. Next RTH Open: legacy roll at 9:30.")

show_pdc   = input.bool(true,     "Show Previous Day Close",     group = "Levels: Prev Day Close")
pdc_color  = input.color(#00ffff, "PDC Color",                   group = "Levels: Prev Day Close",
     tooltip = "Last trade before the 4:00pm ET RTH close, for both equities and futures.")

show_pm    = input.bool(true,     "Show Premarket High/Low",     group = "Levels: Premarket")
ph_color   = input.color(#81c583, "Premarket High Color",        group = "Levels: Premarket")
pl_color   = input.color(#ee9899, "Premarket Low Color",         group = "Levels: Premarket")
pm_opt     = input.string("4:00am-9:30am ET", "Premarket Session",
     options = ["4:00am-9:30am ET", "6:00pm-9:30am ET (Full Overnight)"], group = "Levels: Premarket",
     tooltip = "For futures, use Full Overnight to capture the entire Globex session.")

show_wk    = input.bool(true,     "Show Weekly High/Low",        group = "Levels: Weekly")
wh_color   = input.color(#ffffff, "Weekly High Color",           group = "Levels: Weekly")
wl_color   = input.color(#ffff00, "Weekly Low Color",            group = "Levels: Weekly",
     tooltip = "Running high/low of the current week (week begins at the Sunday 18:00 ET session open). Non-repainting.")

// Levels: Camarilla (v4.4 — engine identical to Kangaroo Tail v1.9.1)
show_cam     = input.bool(true, "Show Camarilla R3/R4 · S3/S4", group = "Levels: Camarilla",
     tooltip = "R3/R4 = CP + range x 1.1/4 and x 1.1/2; S3/S4 mirrored. Turn off to hide all Camarilla levels.")
show_cam6    = input.bool(true, "Show R6 / S6", group = "Levels: Camarilla",
     tooltip = "R6 = CP x H / L. S6 = 2 x CP - R6, a reflection of R6 about the close.")
show_camcp   = input.bool(true, "Show CP (Camarilla close)", group = "Levels: Camarilla",
     tooltip = "The close the pivots are built from. Equals PDC on RTH-data days; on ETH-data days it is the ETH close and can differ from PDC.")
cam_r_color  = input.color(#ff5252, "Resistance Color (R)", group = "Levels: Camarilla")
cam_s_color  = input.color(#4caf50, "Support Color (S)",    group = "Levels: Camarilla")
cam_cp_color = input.color(#2962ff, "CP Color",             group = "Levels: Camarilla")
camSrc       = input.string("Auto", "Camarilla Data", options = ["Auto", "Force RTH", "Force ETH"], group = "Levels: Camarilla",
     tooltip = "Auto: yesterday's RTH H/L unless yesterday's post-market or today's premarket (futures: from 18:00) extended beyond it by more than the tolerance below — then the full ETH day. The premarket is watched live, so pivots can step during the session. Equities need extended hours ON.")
camCls       = input.string("Auto", "Camarilla Close", options = ["Auto", "Force RTH", "Force ETH"], group = "Levels: Camarilla",
     tooltip = "Auto: RTH close with RTH data, ETH close (last bar before the new session) with ETH data. Force either one regardless of the data in use.")
camTol       = input.float(2.0, "ETH Switching Tolerance (% of Daily ATR)", minval = 0.0, step = 0.1, group = "Levels: Camarilla",
     tooltip = "How far outside yesterday's RTH range the post-market or premarket must trade before Auto switches to ETH data. Default: 2.")

// Range: volatility context
show_atr   = input.bool(true,     "Show ATR in Dashboard",       group = "Range: ATR")
atr_len    = input.int(14,        "ATR Length (days)",           group = "Range: ATR", minval = 1, maxval = 100)
show_bands = input.bool(false,    "Show ATR Projection Bands",   group = "Range: ATR",
     tooltip = "Projects Today's Low + ATR and Today's High - ATR as live exhaustion estimates. When the bands invert, the day has exceeded its average range.")
band_color = input.color(#ff9800, "ATR Band Color",              group = "Range: ATR")

// Participation: relative volume
show_rvol  = input.bool(true,     "Show RVOL in Dashboard",      group = "Participation: RVOL")
rvol_len   = input.int(20,        "RVOL Lookback (days)",        group = "Participation: RVOL", minval = 5, maxval = 50)
rvol_thr   = input.float(80.0,    "RVOL Green Threshold %",      group = "Participation: RVOL", minval = 1.0, maxval = 500.0, step = 5.0,
     tooltip = "RVOL compares today's cumulative RTH volume to the average cumulative volume at the same elapsed time of day.")

// Dashboard
dash_pos_s = input.string("Top Center", "Dashboard Position",
     options = ["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = "Dashboard")
dash_size  = input.string("Normal", "Dashboard Text Size", options = ["Small", "Normal", "Large"], group = "Dashboard")

// Style
line_width = input.int(1, "Line Width", minval = 1, maxval = 4,  group = "Style")
show_lbls  = input.bool(true, "Show Labels",                     group = "Style")
lbl_offset = input.int(20, "Label Offset (bars)", minval = 0,    group = "Style")

// Sessions
mktHrs     = input.session("0930-1600", "Market Hours (RTH)",    group = "Sessions")
tz         = input.string("America/New_York", "Time Zone",       group = "Sessions")

// ─── SESSION STATE ───────────────────────────────────────────────────────────
pmSess  = pm_opt == "4:00am-9:30am ET" ? "0400-0930" : "1800-0930"

inRTH   = not na(time(timeframe.period, mktHrs, tz))
inPM    = not na(time(timeframe.period, pmSess, tz))
rthOpen = inRTH and not inRTH[1]
pmStart = inPM and not inPM[1]

// v4.1 — self-derived boundaries. timeframe.change() missed the weekly reset
// v4.3 — DST-proof boundaries. The prior version shifted RAW UTC by 6h, so
// during daylight saving the "18:00" boundary fired at 2:00 PM ET (AAPL Jul:
// yesterday's high truncated mid-session). Read the calendar in exchange time
// instead: a bar's session-day is the New-York calendar day of (time + 6h),
// which maps the 18:00 ET open to the next midnight year-round, EST or EDT.
bT       = time + 6 * 60 * 60 * 1000            // shift so 18:00 ET → next day 00:00
sessDay  = dayofmonth(bT, "America/New_York") + month(bT, "America/New_York") * 100 + year(bT, "America/New_York") * 10000
sessWeek = weekofyear(bT, "America/New_York") + year(bT, "America/New_York") * 100
newDay   = ta.change(sessDay)  != 0
newWeek  = ta.change(sessWeek) != 0

// Session length in minutes, derived from the Market Hours input
sessMinutes(string s) =>
    b  = str.tonumber(str.substring(s, 0, 4))
    e  = str.tonumber(str.substring(s, 5, 9))
    bm = math.floor(b / 100) * 60 + b % 100
    em = math.floor(e / 100) * 60 + e % 100
    math.max(int(em - bm), 1)
var int SESS_MINS = sessMinutes(mktHrs)

// ─── LAYER 1: LOCATION (STRUCTURE LEVELS) ────────────────────────────────────
var float tdHi = na, var float tdLo = na          // today's running H/L
var float yHi  = na, var float yLo  = na          // yesterday (frozen)
var float pmHiAcc = na, var float pmLoAcc = na    // premarket accumulators
var float pmHi = na, var float pmLo = na          // premarket (live in PM, then frozen)
var float lastRthClose = na, var float pdc = na   // previous day close
var float wkHi = na, var float wkLo = na          // current week running H/L

// Resolve the effective roll boundary. Auto: futures roll at 18:00 session
// open (newDay), everything else at the next RTH open (rthOpen). Manual: use
// the dropdown. In full-session mode (yest_rth off) the roll is always newDay.
useNextOpen = rollMode == "Auto" ? (syminfo.type != "futures") : (rollOpt == "Next RTH Open")
rollB = useNextOpen ? rthOpen : newDay
// Freeze yesterday at the roll boundary, then reset today's accumulators
dayBoundary = yest_rth ? rollB : newDay
if dayBoundary
    yHi  := tdHi
    yLo  := tdLo
    tdHi := na
    tdLo := na

// PDC rolls with yesterday; premarket levels freeze at the RTH open
if rollB
    pdc  := lastRthClose
if rthOpen
    pmHi := pmHiAcc
    pmLo := pmLoAcc

// Reset premarket accumulators when a new premarket window begins
if pmStart
    pmHiAcc := na
    pmLoAcc := na

// Accumulate today's high/low (RTH-only or full session day)
if yest_rth ? inRTH : true
    tdHi := na(tdHi) ? high : math.max(tdHi, high)
    tdLo := na(tdLo) ? low  : math.min(tdLo, low)

// Track the most recent RTH close (becomes PDC at the next open)
if inRTH
    lastRthClose := close

// Accumulate premarket high/low, updating live during PM
if inPM
    pmHiAcc := na(pmHiAcc) ? high : math.max(pmHiAcc, high)
    pmLoAcc := na(pmLoAcc) ? low  : math.min(pmLoAcc, low)
    pmHi := pmHiAcc
    pmLo := pmLoAcc

// Weekly running high/low
if newWeek
    wkHi := na
    wkLo := na
wkHi := na(wkHi) ? high : math.max(wkHi, high)
wkLo := na(wkLo) ? low  : math.min(wkLo, low)

// ─── LAYER 2: RANGE (ATR + RANGE USED) ───────────────────────────────────────
// ATR from completed daily bars only: stable all day, never repaints
atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atr_len)[1],
     lookahead = barmerge.lookahead_off)

todayRange  = not na(tdHi) and not na(tdLo) ? tdHi - tdLo : na
atrUsedPct  = not na(todayRange) and not na(atrDaily) and atrDaily > 0 ? todayRange / atrDaily * 100 : na

// ATR projection bands (live exhaustion estimates)
atrBandHi = show_bands and not na(tdLo) and not na(atrDaily) ? tdLo + atrDaily : na
atrBandLo = show_bands and not na(tdHi) and not na(atrDaily) ? tdHi - atrDaily : na

// ─── CAMARILLA ENGINE (v4.4 — identical to Kangaroo Tail v1.9.1) ─────────────
// Own accumulators, independent of YH/YL/PDC. Session markers:
//   futures:  RTH = Market Hours input; post starts at RTH end;
//             session first bar (18:00) = new ETH day + premarket start
//   equities: exchange sessions; premarket first bar (4:00) = new ETH day
camFut     = syminfo.type == "futures"
cInRth     = camFut ? inRTH : session.ismarket
cRegStart  = camFut ? (inRTH and not inRTH[1]) : session.isfirstbar_regular
cPostStart = camFut ? (inRTH[1] and not inRTH) : ((session.ispostmarket and session.ismarket[1]) or (session.isfirstbar and session.ismarket[1]))
cPreStart  = camFut ? session.isfirstbar : ((session.ispremarket and session.isfirstbar) or (session.isfirstbar and session.isfirstbar_regular))
bsPre      = ta.barssince(cPreStart)
bsReg      = ta.barssince(cRegStart)
cInPre     = camFut ? (bsPre < bsReg) : session.ispremarket

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

// Pivots. R6 = C x H / L; S6 = 2C - R6 (a reflection about the close, not C x L / H)
camRng = not na(camH) and not na(camL) ? camH - camL : na
camR3  = not na(camRng) and not na(camCP) ? camCP + camRng * 1.1 / 4.0 : na
camR4  = not na(camRng) and not na(camCP) ? camCP + camRng * 1.1 / 2.0 : na
camS3  = not na(camRng) and not na(camCP) ? camCP - camRng * 1.1 / 4.0 : na
camS4  = not na(camRng) and not na(camCP) ? camCP - camRng * 1.1 / 2.0 : na
camR6  = not na(camH) and not na(camL) and not na(camCP) and camL != 0 ? camCP * camH / camL : na
camS6  = not na(camR6) and not na(camCP) ? 2.0 * camCP - camR6 : na

// Line start: the bar where the current level set began
var int camStart = na
camChg = nz(camR3) != nz(camR3[1]) or nz(camS3) != nz(camS3[1]) or nz(camCP) != nz(camCP[1]) or nz(camR6) != nz(camR6[1])
if camChg or na(camStart)
    camStart := bar_index

// ─── LAYER 3: PARTICIPATION (RVOL) ───────────────────────────────────────────
// Time-of-day cumulative volume profiling: today's cumulative RTH volume vs.
// the N-day average cumulative volume at the same elapsed minute of the session.
var matrix<float> volProfiles = matrix.new<float>(0, SESS_MINS)
var float rthCumVol = 0.0
var int   rthOpenMs = 0
var int   dayRow    = -1
var float rvolPct   = na

if show_rvol and timeframe.isintraday
    if rthOpen
        rthCumVol := 0.0
        rthOpenMs := time
        volProfiles.add_row(volProfiles.rows())
        if volProfiles.rows() > rvol_len + 1
            volProfiles.remove_row(0)
        dayRow := volProfiles.rows() - 1
    if inRTH and dayRow >= 0
        rthCumVol += volume
        m = math.min(math.floor((time - rthOpenMs) / 60000), SESS_MINS - 1)
        volProfiles.set(dayRow, m, rthCumVol)
        completedDays = volProfiles.rows() - 1
        if completedDays > 0
            sumHist = 0.0
            valid   = 0
            for r = 0 to completedDays - 1
                hv = volProfiles.get(r, m)
                if hv > 0
                    sumHist += hv
                    valid   += 1
            rvolPct := valid > 0 ? rthCumVol / (sumHist / valid) * 100 : na
    if not inRTH
        rvolPct := na

// ─── DRAWING: LEVEL LINES ────────────────────────────────────────────────────
var array<line>   lvlLines  = array.new<line>(9, na)
var array<label>  lvlLabels = array.new<label>(9, na)
var array<color>  lvlColors = array.from(yh_color, yl_color, pdc_color, ph_color, pl_color, wh_color, wl_color, band_color, band_color)
var array<string> lvlNames  = array.from("YH", "YL", "PDC", "PMH", "PML", "WH", "WL", "ATR H", "ATR L")

lvlValues = array.from(yHi, yLo, pdc, pmHi, pmLo, wkHi, wkLo, atrBandHi, atrBandLo)
lvlShows  = array.from(show_yest, show_yest, show_pdc, show_pm, show_pm, show_wk, show_wk, show_bands, show_bands)

for i = 0 to 8
    if lvlShows.get(i) and not na(lvlValues.get(i))
        v  = lvlValues.get(i)
        ln = lvlLines.get(i)
        if na(ln)
            lvlLines.set(i, line.new(bar_index, v, bar_index + 1, v,
                 color = lvlColors.get(i), style = i >= 7 ? line.style_dotted : line.style_dashed,
                 width = line_width, extend = extend.right))
        else
            ln.set_y1(v)
            ln.set_y2(v)

// ─── DRAWING: LABELS ─────────────────────────────────────────────────────────
if barstate.islast and show_lbls
    lx = bar_index - lbl_offset
    for i = 0 to 8
        lbl = lvlLabels.get(i)
        if not na(lbl)
            label.delete(lbl)
        if lvlShows.get(i) and not na(lvlValues.get(i))
            c = lvlColors.get(i)
            lvlLabels.set(i, label.new(lx, lvlValues.get(i), lvlNames.get(i),
                 color = color.new(c, 70), textcolor = c,
                 style = label.style_label_center, size = size.small))

// ─── DRAWING: CAMARILLA ──────────────────────────────────────────────────────
var array<line>   camLines  = array.new<line>(7, na)
var array<label>  camLabels = array.new<label>(7, na)
var array<string> camNames  = array.from("R6", "R4", "R3", "CP", "S3", "S4", "S6")
if barstate.islast
    camVals = array.from(camR6, camR4, camR3, camCP, camS3, camS4, camS6)
    camOn   = array.from(show_cam and show_cam6, show_cam, show_cam, show_cam and show_camcp, show_cam, show_cam, show_cam and show_cam6)
    for i = 0 to 6
        oldLn = camLines.get(i)
        oldLb = camLabels.get(i)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)
        camLines.set(i, na)
        camLabels.set(i, na)
        v = camVals.get(i)
        if camOn.get(i) and not na(v) and not na(camStart)
            c = i < 3 ? cam_r_color : i == 3 ? cam_cp_color : cam_s_color
            camLines.set(i, line.new(camStart, v, bar_index + 1, v, color = c,
                 style = line.style_solid, width = line_width, extend = extend.right))
            if show_lbls
                camLabels.set(i, label.new(math.max(bar_index - lbl_offset, camStart), v, camNames.get(i),
                     color = color.new(c, 70), textcolor = c, style = label.style_label_center, size = size.small))

// ─── DRAWING: DASHBOARD ──────────────────────────────────────────────────────
var dashPos = switch dash_pos_s
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right
var dashTxt = dash_size == "Small" ? size.small : dash_size == "Large" ? size.large : size.normal

var table dash = na
if barstate.islast and (show_rvol or show_atr or show_cam)
    if na(dash)
        dash := table.new(dashPos, 2, 4,
             bgcolor = color.new(color.black, 55),
             border_color = color.new(color.gray, 50), border_width = 1,
             frame_color = color.new(color.gray, 50), frame_width = 1)
    row = 0
    if show_rvol
        rvolStr = na(rvolPct) ? "N/A" : str.tostring(rvolPct, "#.0") + "%"
        rvolClr = na(rvolPct) ? color.gray : rvolPct >= rvol_thr ? #00ff00 : #ff5050
        dash.cell(0, row, "RVOL", text_color = color.white, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        dash.cell(1, row, rvolStr, text_color = rvolClr, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        row += 1
    if show_atr
        atrStr = na(atrDaily) ? "N/A" : str.tostring(atrDaily, format.mintick)
        dash.cell(0, row, "ATR(" + str.tostring(atr_len) + "d)", text_color = color.white, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        dash.cell(1, row, atrStr, text_color = color.white, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        row += 1
        usedStr = na(atrUsedPct) ? "N/A" : str.tostring(atrUsedPct, "#.0") + "%"
        usedClr = na(atrUsedPct) ? color.gray : atrUsedPct < 70 ? #00ff00 : atrUsedPct <= 100 ? #ff9800 : #ff5050
        dash.cell(0, row, "Range/ATR", text_color = color.white, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        dash.cell(1, row, usedStr, text_color = usedClr, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        row += 1
    if show_cam
        camStr = na(camRng) ? "N/A" : camUseEth ? "ETH" : "RTH"
        camClr = na(camRng) ? color.gray : camUseEth ? #ff9800 : color.white
        dash.cell(0, row, "Cams", text_color = color.white, text_size = dashTxt, bgcolor = color.new(color.black, 55))
        dash.cell(1, row, camStr, text_color = camClr, text_size = dashTxt, bgcolor = color.new(color.black, 55))

// ─── PRICE AXIS DISPLAY ──────────────────────────────────────────────────────
plot(show_yest  ? yHi  : na, "Yesterday High",     yh_color,   editable = false, display = display.price_scale)
plot(show_yest  ? yLo  : na, "Yesterday Low",      yl_color,   editable = false, display = display.price_scale)
plot(show_pdc   ? pdc  : na, "Previous Day Close", pdc_color,  editable = false, display = display.price_scale)
plot(show_pm    ? pmHi : na, "Premarket High",     ph_color,   editable = false, display = display.price_scale)
plot(show_pm    ? pmLo : na, "Premarket Low",      pl_color,   editable = false, display = display.price_scale)
plot(show_wk    ? wkHi : na, "Weekly High",        wh_color,   editable = false, display = display.price_scale)
plot(show_wk    ? wkLo : na, "Weekly Low",         wl_color,   editable = false, display = display.price_scale)
plot(show_bands ? atrBandHi : na, "ATR Band High", band_color, editable = false, display = display.price_scale)
plot(show_bands ? atrBandLo : na, "ATR Band Low",  band_color, editable = false, display = display.price_scale)
plot(show_cam and show_cam6  ? camR6 : na, "Camarilla R6", cam_r_color,  editable = false, display = display.price_scale)
plot(show_cam                ? camR4 : na, "Camarilla R4", cam_r_color,  editable = false, display = display.price_scale)
plot(show_cam                ? camR3 : na, "Camarilla R3", cam_r_color,  editable = false, display = display.price_scale)
plot(show_cam and show_camcp ? camCP : na, "Camarilla CP", cam_cp_color, editable = false, display = display.price_scale)
plot(show_cam                ? camS3 : na, "Camarilla S3", cam_s_color,  editable = false, display = display.price_scale)
plot(show_cam                ? camS4 : na, "Camarilla S4", cam_s_color,  editable = false, display = display.price_scale)
plot(show_cam and show_cam6  ? camS6 : na, "Camarilla S6", cam_s_color,  editable = false, display = display.price_scale)
````

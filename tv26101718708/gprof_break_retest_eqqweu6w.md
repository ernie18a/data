# GProf - Break & Retest

- url: https://www.tradingview.com/script/eqqWEu6W-GProf-Break-Retest/
- type: indicator
- pine_id: PUB;c2fb54e43a89426881e3e316e99648dc
- version: 1.0

## Description

GProf - Break & Retest
═══════════════════════════════════════════

OVERVIEW

This indicator detects one complete sequence: consolidation against a key level, a breakout WITH momentum, and the retest of the broken level. It watches the levels for you, stays silent through weak drifts and fakeouts, and speaks at the two moments that matter — when a level breaks with force, and when price comes back to test it.

The core idea is polarity: a level that held for hours gets violated with conviction, and the trade is the market returning to confirm the flip — old support rejecting as new resistance, or old resistance holding as new support.

───────────────────────────────────────────
TWO CONSOLIDATION PATTERNS, ONE CONFIRMATION GATE

PATTERN 1 — TIGHT COIL: a short compressed window pressing directly against the level, with zero closes beyond it. Price knocking on a door.

PATTERN 2 — RANGE-SIT: price spends an extended window entirely on one side of the level, the whole range within a capped height of it, then breaks the boundary. This captures the classic premarket-range breakout or breakdown, where the premarket high or low is the boundary of the consolidation itself.

Either pattern must then be CONFIRMED. A break with no force is fully silent — no label, no alert:

• MOMENTUM CANDLE — the breakout (or a continuation candle within a few bars) has a body of at least a set percentage of the daily ATR; OR
• QUALIFIED FVG — a Fair Value Gap of a set minimum size prints within the confirmation window.

Whichever arrives first arms the setup, and the alert tells you which one it was.

───────────────────────────────────────────
LEVELS AND THE ONE-BREAK DOCTRINE

Tracked levels: PMH/PML, YH/YL, PDC, WH/WL — computed internally, non-repainting, with session boundaries read in exchange time so they hold up through daylight-saving changes and holiday-shortened weeks.

LIFETIME VIRGINITY: a level may signal ONE break per lifetime. The first close beyond it consumes the level; wicks never spend it — sweeps that close back are probes, not violations. A spent level renews when its value changes or at the session roll. This kills re-break noise: a level violated at midday cannot fire again in the evening.

LIVE-LEVEL MATURITY: running levels (WH/WL always; PMH/PML while the premarket window is open) must rest untouched for a set number of bars before they can arm — every new weekly high is technically a "break of WH," and this suppresses that churn while keeping the first quality break.

WHEN "YESTERDAY" ROLLS: Roll Mode is Auto by default — futures roll at the 18:00 ET session open, equities at the next regular-session open — so evening and overnight sessions trade against the levels of the session that just completed.

The full doctrine in one sentence: a level may signal one break per lifetime, provided it has aged while live and is broken with momentum.

───────────────────────────────────────────
THE RETEST — TWO SPECIES

IMMEDIATE KISS-BACK: while the breakout leg is still building, a return to within tolerance of the broken level fires the retest — the fast test-and-reject, often within a bar or two of the break.

SWING 50% RETEST: if price runs instead, the swing confirms, the leg's 50% level is drawn, and the deeper retracement to the 50% or the level — whichever price reaches first — fires the retest.

A+ FLAG: when the leg's 50% coincides with the broken level itself, the retest is tagged A+ — two independent trade logics agreeing on one price.

───────────────────────────────────────────
SIGNALS AND ALERTS

On the chart: the consolidation box, a "B&R [LEVEL]" label on the confirmed break, a dotted 50% line once the swing confirms, and a "RETEST [LEVEL]" label (with A+ when earned). Breaks that armed but failed are marked with a small x; unconfirmed breaks leave no trace.

Two independent alert stages, each toggleable:
• CONFIRMED BREAKOUT — the level, the direction, and which confirmation fired.
• RETEST ENTERED — the level and price, with the A+ tag when the 50% sits on the level. Off by default; many traders use the breakout alert to get to the chart and watch the retest form.

Alert setup: ONE alert per chart, condition "Any alert() function call", expiration Open-ended. The toggles in settings control what fires. Note: TradingView alerts snapshot settings at creation — after changing settings, recreate the alert.

───────────────────────────────────────────
HOW TO USE IT

Traders who study break-and-retest setups typically treat the breakout alert as the heads-up and the retest as the decision point — watching for a confirmation candle at the retest before acting. The consolidation box shows you what broke; the tags tell you how it was confirmed.

This indicator identifies structure and sequence. It does not generate buy/sell recommendations, does not place trades, and does not replace your own analysis and risk management.

───────────────────────────────────────────
TECHNICAL NOTES

• Non-repainting: every state transition confirms on bar close; ATR uses completed daily bars; no lookahead anywhere.
• Intraday timeframes only. Built for index and commodity futures but works on any liquid symbol; thresholds are a percentage of daily ATR with tick floors, so they travel across instruments and volatility regimes.
• Coil and range windows, momentum and FVG thresholds, maturity, timeouts, retest tolerance, and session times are fully configurable.

───────────────────────────────────────────
DISCLAIMER

This script is for informational and educational purposes only. It does not constitute financial, investment, or trading advice. A broken level retesting is a pattern, not a guarantee of future price behavior. All trading decisions made using this tool are solely the responsibility of the user.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  GProf - Break & Retest  v1.3
//  Two consolidation pattern classes, one confirmation gate:
//
//  PATTERN 1 — TIGHT COIL: a short compressed window pressing
//  against a level (v1.2 logic).
//  PATTERN 2 — RANGE-SIT: price spends an extended window
//  entirely on one side of the level, the whole range within a
//  capped height of it, then breaks the boundary. Captures
//  premarket-range breakdowns/breakouts, where PML/PMH ARE the
//  boundaries of the consolidation itself (MES Jul 7 case).
//
//  Either pattern → break of the level → confirmation required:
//  momentum candle (body >= threshold) OR qualified FVG within
//  K bars — otherwise fully silent. Then swing confirm → 50%
//  drawn → optional RETEST alert. A+ = 50% coincides with level.
//
//  CLEAN HISTORY: no closes beyond the level within the last C
//  bars (the room-to-the-left dial; raise to filter levels that
//  were violated recently).
//
//  v1.1 — Tick floors on coil proximity/height (MES fix).
//  v1.2 — Window-touch coil; momentum-or-FVG gate; silent fails.
//  v1.3 — RANGE-SIT pattern class + Clean History filter.
//  v1.4 — Range-path fixes: (1) wick tolerance — prior-window
//         pokes beyond the level allowed up to the proximity
//         band (was 2 ticks; a pre-break probe wick killed the
//         test). (2) Transition semantics — the range test now
//         runs only at the crossing bar (prior close on the
//         correct side), so the break's own closes can never
//         contaminate the Clean History lookback. Confirmation
//         then proceeds via the silent state as usual.
//  v1.5 — Two retest species. IMMEDIATE kiss-back: while the
//         leg is still building, a return to within tolerance
//         of the broken level fires the retest (MES Jul 7 —
//         the retest printed one bar after the break, while
//         the machine waited for swing confirmation). SWING
//         50% retest unchanged for deeper retracements. Armed
//         timeout raised 20 → 40 bars (a 15-bar leg + swing
//         confirm was expiring before the 50% was ever reached).
//  v1.6 — Running-level maturity (WH/WL): the level must be
//         untouched for N bars (default 48) before it can arm.
//         Every break of a running extreme updates the level
//         and resets the clock, so repeat signals during the
//         same trend day are suppressed automatically — first
//         quality break kept, echoes silenced. Daily levels
//         (PMH/PML/YH/YL/PDC) exempt: they freeze on schedule
//         and early-session breaks of them are core setups.
//  v1.7 — Maturity follows LIVENESS, not level identity. PMH/
//         PML are running levels while the premarket window is
//         open (a PML minted two candles after 4:00am is not
//         structure — MES Jul 8 case) and are maturity-gated
//         during that window; exempt after the 9:30 freeze, so
//         open-drive breaks of frozen PM levels are unaffected.
//         WH/WL always gated; YH/YL/PDC never.
//  v1.8 — LIFETIME VIRGINITY. A level may signal ONE break per
//         lifetime: the first CLOSE beyond it consumes the level
//         (wicks never spend — sweeps that close back are probes,
//         not violations). Spent levels renew when their value
//         changes or at the session freeze. Kills re-break
//         signals against already-violated levels (MES Jul 8 —
//         evening YL break hours after the RTH breakdown).
//         PDC spends per-direction. Replaces the rolling Clean
//         History window, which was the wrong abstraction:
//         cleanliness is a property of the level's life, not of
//         the last N bars. Doctrine: a level may signal one
//         break per lifetime, provided it has aged while live
//         and is broken with momentum.
//  v1.9 — "Yesterday Rolls At" input (default: 18:00 Session
//         Open, CME's day boundary). YH/YL/PDC roll — and their
//         virginity renews — at the Globex open, so an evening
//         break of today's completed levels can signal. "Next
//         RTH Open" retained as the legacy option. Suite-wide
//         change, shipped with LRA v4.2 and KT v1.6.
//  v2.0 — DST-proof boundaries + Roll Mode Auto/Manual (matches
//         LRA v4.3): the raw-UTC shift fired "18:00" at 2 PM ET
//         under daylight saving, truncating yesterday's levels.
//         Auto detects instrument type — futures roll at 18:00,
//         equities at the next RTH open — no setting to change
//         when switching between futures and stocks.
// ─────────────────────────────────────────────────────────────
indicator("GProf - Break & Retest", "GProf B&R", overlay = true,
     max_boxes_count = 100, max_lines_count = 100, max_labels_count = 300)

// ── Inputs ───────────────────────────────────────────────────
grpC = "Pattern 1: Tight Coil"
useCoil  = input.bool(true, "Enable Tight Coil Detection", group = grpC)
coilN    = input.int(6,    "Coil Window (bars)",            minval = 3, maxval = 30, group = grpC)
proxPct  = input.float(0.75, "Proximity Band (% of Daily ATR)", minval = 0.05, step = 0.05, group = grpC)
proxFlr  = input.int(16,   "Proximity Floor (ticks)",       minval = 0, group = grpC)
maxHPct  = input.float(1.5,  "Max Coil Height (% of Daily ATR)", minval = 0.1, step = 0.1, group = grpC)
maxHFlr  = input.int(40,   "Max Coil Height Floor (ticks)", minval = 0, group = grpC)

grpC2 = "Pattern 2: Range-Sit"
useRange = input.bool(true, "Enable Range-Sit Detection", group = grpC2,
     tooltip = "Price spends the whole lookback window on one side of the level, within the height cap, then breaks the boundary. Captures premarket-range breakdowns where PML/PMH are the range edges themselves.")
rangeM   = input.int(24,   "Range Lookback (bars)",         minval = 6, maxval = 100, group = grpC2)
rCapPct  = input.float(20.0, "Max Range Height Above/Below Level (% of Daily ATR)", minval = 1.0, step = 0.5, group = grpC2)
rCapFlr  = input.int(80,   "Max Range Height Floor (ticks)", minval = 0, group = grpC2)

grpB = "Breakout Confirmation (Momentum OR FVG)"
bufTicks = input.int(2,    "Breakout Buffer (ticks)",       minval = 0, group = grpB)
momPct   = input.float(2.5,  "Momentum Candle Body (% of Daily ATR)", minval = 0.1, step = 0.1, group = grpB)
momFlr   = input.int(12,   "Momentum Body Floor (ticks)",   minval = 0, group = grpB)
fvgK     = input.int(3,    "Confirmation Window (bars)",    minval = 1, maxval = 10, group = grpB)
fvgPct   = input.float(2.0,  "FVG Min Size (% of Daily ATR)", minval = 0.1, step = 0.05, group = grpB)
fvgTicks = input.int(10,   "FVG Min Size Floor (ticks)",    minval = 0, group = grpB)
atrLenIn = input.int(14,   "ATR Length (days)",             minval = 1, group = grpB)

grpR = "Retest Stage"
swingN   = input.int(3,    "Swing Confirm (bars)",          minval = 1, maxval = 10, group = grpR)
toBars   = input.int(40,   "Armed Timeout (bars)",          minval = 5, maxval = 200, group = grpR,
     tooltip = "Whole-setup lifetime from the break. Strong legs can extend 15+ bars before the swing confirms; keep this generous.")
retestT  = input.int(2,    "Immediate Retest Tolerance (ticks)", minval = 0, group = grpR,
     tooltip = "While the leg is still building, a return to within this many ticks of the broken level fires the retest — the fast kiss-back entry. The swing 50% retest remains active for deeper retracements.")
aplusPct = input.float(0.3,  "A+ Overlap Band (% of Daily ATR)", minval = 0.05, step = 0.05, group = grpR)

grpL = "Levels"
en_pm   = input.bool(true, "PMH / PML",  group = grpL)
en_yd   = input.bool(true, "YH / YL",    group = grpL)
en_pdc  = input.bool(true, "PDC (both directions)", group = grpL)
en_wk   = input.bool(true, "WH / WL",    group = grpL)
matureB = input.int(48, "Live Level Maturity (bars)", minval = 0, maxval = 500, group = grpL,
     tooltip = "Applies while a level is still ACCUMULATING: WH/WL always; PMH/PML during the open premarket window. The level must be untouched for this many bars before a coil or break against it can signal. Frozen levels (YH/YL/PDC, and PMH/PML after the 9:30 freeze) are exempt — they are structure by construction. Suppresses breaks of newborn levels (e.g. a PML minted minutes after the premarket opens).")
yest_rth = input.bool(true, "Yesterday RTH Only (9:30-16:00 ET)", group = grpL)
rollMode = input.string("Auto", "Roll Mode", options = ["Auto", "Manual"], group = grpL,
     tooltip = "Auto (default): futures roll yesterday at the 18:00 ET session open; equities/other at the next RTH open. Detected from instrument type. Manual: use the setting below.")
rollOpt  = input.string("18:00 Session Open", "Yesterday Rolls At (Manual)", options = ["18:00 Session Open", "Next RTH Open"], group = grpL,
     tooltip = "Only used when Roll Mode = Manual.")
pm_opt  = input.string("4:00am-9:30am ET", "Premarket Session",
     options = ["4:00am-9:30am ET", "6:00pm-9:30am ET (Full Overnight)"], group = grpL)
mktHrs  = input.session("0930-1600", "Market Hours (RTH)", group = grpL)
tz      = input.string("America/New_York", "Time Zone",    group = grpL)

grpA = "Alerts"
alSignal = input.bool(true,  "Alert: Confirmed Breakout (Armed)", group = grpA)
alRetest = input.bool(false, "Alert: Retest Entered",             group = grpA)

grpS = "Display"
coilColL = input.color(color.new(color.teal, 85), "Consolidation Box (Long)",  group = grpS)
coilColS = input.color(color.new(color.red, 85),  "Consolidation Box (Short)", group = grpS)
show50   = input.bool(true, "Draw Leg 50% Line When Armed", group = grpS)

// ── Daily ATR (completed bars — non-repainting) ──────────────
atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atrLenIn)[1], lookahead = barmerge.lookahead_off)
prox   = math.max(proxPct  / 100.0 * atrDaily, proxFlr * syminfo.mintick)
maxH   = math.max(maxHPct  / 100.0 * atrDaily, maxHFlr * syminfo.mintick)
rCap   = math.max(rCapPct  / 100.0 * atrDaily, rCapFlr * syminfo.mintick)
aplusB = math.max(aplusPct / 100.0 * atrDaily, 4 * syminfo.mintick)
momThr = math.max(momPct   / 100.0 * atrDaily, momFlr * syminfo.mintick)
buf    = bufTicks * syminfo.mintick
effFvg = na(atrDaily) ? na : math.max(fvgPct / 100.0 * atrDaily, fvgTicks * syminfo.mintick)

// ── Session engine (from LRA v4.1) ──────────────────────
pmSess  = pm_opt == "4:00am-9:30am ET" ? "0400-0930" : "1800-0930"
inRTH   = not na(time(timeframe.period, mktHrs, tz))
inPM    = not na(time(timeframe.period, pmSess, tz))
rthOpen = inRTH and not inRTH[1]
pmStart = inPM and not inPM[1]
// v2.0 — DST-proof boundaries (matches LRA v4.3): read the calendar in
// America/New_York instead of shifting raw UTC, so 18:00 ET maps to the next
// midnight year-round (EST or EDT). The prior raw-UTC shift fired "18:00" at
// 2 PM ET under daylight saving, truncating yesterday's levels.
bT       = time + 6 * 60 * 60 * 1000
sessDay  = dayofmonth(bT, "America/New_York") + month(bT, "America/New_York") * 100 + year(bT, "America/New_York") * 10000
sessWeek = weekofyear(bT, "America/New_York") + year(bT, "America/New_York") * 100
newDay   = ta.change(sessDay)  != 0
newWeek  = ta.change(sessWeek) != 0

// ── Level accumulators (from LRA v4.1) ──────────────────
var float tdHi = na, var float tdLo = na
var float yHi  = na, var float yLo  = na
var float pmHiAcc = na, var float pmLoAcc = na
var float pmHi = na, var float pmLo = na
var float lastRthClose = na, var float pdc = na
var float wkHi = na, var float wkLo = na

useNextOpen = rollMode == "Auto" ? (syminfo.type != "futures") : (rollOpt == "Next RTH Open")
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

// ── Bar qualities ────────────────────────────────────────────
bullFVG  = low > high[2]
bearFVG  = high < low[2]
qualBull = bullFVG and not na(effFvg) and (low - high[2])  >= effFvg
qualBear = bearFVG and not na(effFvg) and (low[2] - high) >= effFvg
bodySz   = math.abs(close - open)
momUp    = bodySz >= momThr and close > open
momDn    = bodySz >= momThr and close < open

winHi  = ta.highest(high, coilN)
winLo  = ta.lowest(low, coilN)
rWinHi = ta.highest(high, rangeM)[1]   // range windows exclude the current (break) bar
rWinLo = ta.lowest(low, rangeM)[1]

// Pattern 1 — tight coil pressing the level
coilOK(float L, int dir) =>
    bool closedBeyond = false
    for j = 0 to coilN - 1
        if dir > 0 ? close[j] > L : close[j] < L
            closedBeyond := true
    edgeNear = dir > 0 ? winHi >= L - prox : winLo <= L + prox
    not closedBeyond and edgeNear and (winHi - winLo) <= maxH

// Pattern 2 — range-sit: prior M bars entirely on one side, within rCap of the level
// (history cleanliness is now enforced by lifetime virginity — see spent flag)
rangeSitOK(float L, int dir) =>
    dir > 0 ? (L - rWinLo) <= rCap and rWinHi <= L + prox : (rWinHi - L) <= rCap and rWinLo >= L - prox

// ── State machine (8 slots: 4 long, 4 short) ─────────────────
// 0 IDLE · 1 COILING · 2 BROKE (silent, awaiting momentum/FVG) · 3 ARMED · 4 AWAIT RETEST
var array<string> names = array.from("PMH", "YH", "PDC", "WH", "PML", "YL", "PDC", "WL")
var array<int>    dirs  = array.from(1, 1, 1, 1, -1, -1, -1, -1)
var array<int>    st      = array.new_int(8, 0)
var array<float>  lv      = array.new_float(8, na)
var array<int>    brBar   = array.new_int(8, 0)
var array<float>  anch    = array.new_float(8, na)
var array<float>  ext     = array.new_float(8, na)
var array<int>    extAge  = array.new_int(8, 0)
var array<float>  f50     = array.new_float(8, na)
var array<int>    lastRes = array.new_int(8, -9999)
var array<float>  prevLv  = array.new_float(8, na)
var array<int>    lastChg = array.new_int(8, -9999)
var array<bool>   spent   = array.new<bool>(8, false)   // lifetime virginity: one signal per level life
var array<box>    cBox    = array.new<box>(8, na)
var array<line>   l50     = array.new<line>(8, na)

resolveSlot(int i) =>
    st.set(i, 0)
    lastRes.set(i, bar_index)

armSlot(int i, int d, string nm, string how) =>
    st.set(i, 3)
    if alSignal
        alert("B&R BREAKOUT: " + syminfo.ticker + " " + timeframe.period + " " +
             (d > 0 ? "above " : "below ") + nm + " " + str.tostring(lv.get(i), format.mintick) +
             " — " + how, alert.freq_once_per_bar)
    label.new(bar_index, d > 0 ? high : low, "B&R " + nm + (d > 0 ? " ▲" : " ▼"),
         style = d > 0 ? label.style_label_down : label.style_label_up,
         color = color.new(d > 0 ? color.teal : color.red, 40), textcolor = color.white, size = size.small)

if barstate.isconfirmed and timeframe.isintraday and not na(atrDaily)
    levVals = array.from(pmHi, yHi, pdc, wkHi, pmLo, yLo, pdc, wkLo)
    enabArr = array.from(en_pm, en_yd, en_pdc, en_wk, en_pm, en_yd, en_pdc, en_wk)
    for i = 0 to 7
        d    = dirs.get(i)
        nm   = names.get(i)
        Llive = levVals.get(i)
        s    = st.get(i)
        // Maturity clock: stamp whenever the level's value changes
        // Value change = the level is reborn: virginity renews
        if not na(Llive) and (na(prevLv.get(i)) or Llive != prevLv.get(i))
            lastChg.set(i, bar_index)
            spent.set(i, false)
        prevLv.set(i, Llive)
        // Frozen levels renew when their values roll (covers identical-value edge):
        // YH/YL/PDC at the roll boundary; PMH/PML at the RTH-open freeze
        if rollB and (i == 1 or i == 2 or i == 5 or i == 6)
            spent.set(i, false)
        if rthOpen and (i == 0 or i == 4)
            spent.set(i, false)
        // Maturity applies while a level is LIVE (still accumulating):
        // WH/WL always; PMH/PML while the premarket window is open.
        // Frozen levels are structure by construction — exempt.
        isLive = i == 3 or i == 7 or ((i == 0 or i == 4) and inPM)
        matOK  = not isLive or bar_index - lastChg.get(i) >= matureB
        virgin = not spent.get(i)
        if not enabArr.get(i)
            if s != 0
                resolveSlot(i)
            continue

        // ---- COILING: break check first (snapshot level), else re-validate coil
        if s == 1
            L = lv.get(i)
            brokeOut = d > 0 ? close > L + buf : close < L - buf
            if brokeOut
                brBar.set(i, bar_index)
                anch.set(i, d > 0 ? winLo : winHi)
                ext.set(i, d > 0 ? high : low)
                extAge.set(i, 0)
                b = cBox.get(i)
                if not na(b)
                    b.set_border_color(d > 0 ? color.teal : color.red)
                if d > 0 ? momUp : momDn
                    armSlot(i, d, nm, "momentum candle, coil break")
                else
                    st.set(i, 2)
            else
                if not na(Llive) and matOK and coilOK(Llive, d)
                    lv.set(i, Llive)
                    b = cBox.get(i)
                    if not na(b)
                        b.set_right(bar_index)
                        b.set_top(d > 0 ? Llive : winHi)
                        b.set_bottom(d > 0 ? winLo : Llive)
                else
                    box.delete(cBox.get(i))
                    cBox.set(i, na)
                    st.set(i, 0)

        // ---- IDLE: range-sit break, or a fresh tight coil (with cooldown)
        else if s == 0
            cooled = bar_index - lastRes.get(i) > coilN
            // Pattern 2: evaluated ONLY at the crossing bar (prior close on the
            // correct side) — the break cannot contaminate its own clean history
            brokeNow = not na(Llive) and (d > 0 ? close > Llive + buf and close[1] <= Llive : close < Llive - buf and close[1] >= Llive)
            if useRange and cooled and matOK and virgin and brokeNow and rangeSitOK(Llive, d)
                lv.set(i, Llive)
                brBar.set(i, bar_index)
                anch.set(i, d > 0 ? math.min(rWinLo, Llive) : math.max(rWinHi, Llive))
                ext.set(i, d > 0 ? high : low)
                extAge.set(i, 0)
                box.delete(cBox.get(i))
                cBox.set(i, box.new(bar_index - rangeM, d > 0 ? Llive : rWinHi, bar_index - 1, d > 0 ? rWinLo : Llive,
                     border_color = color.new(d > 0 ? color.teal : color.red, 60),
                     bgcolor = d > 0 ? coilColL : coilColS))
                if d > 0 ? momUp : momDn
                    armSlot(i, d, nm, "momentum candle, range break")
                else
                    st.set(i, 2)
            else if useCoil and cooled and matOK and virgin and not na(Llive) and coilOK(Llive, d)
                st.set(i, 1)
                lv.set(i, Llive)
                box.delete(cBox.get(i))
                cBox.set(i, box.new(bar_index - coilN + 1, d > 0 ? Llive : winHi, bar_index, d > 0 ? winLo : Llive,
                     border_color = color.new(color.gray, 60), bgcolor = d > 0 ? coilColL : coilColS))

        // ---- BROKE (silent): awaiting momentum candle or qualified FVG
        else if s == 2
            L = lv.get(i)
            ext.set(i, d > 0 ? math.max(ext.get(i), high) : math.min(ext.get(i), low))
            failedBack = d > 0 ? close < L : close > L
            stillBeyond = d > 0 ? close > L : close < L
            if failedBack
                box.delete(cBox.get(i))
                cBox.set(i, na)
                resolveSlot(i)
            else if stillBeyond and (d > 0 ? (momUp or qualBull) : (momDn or qualBear))
                how = (d > 0 ? qualBull : qualBear) ? "FVG confirmation" : "momentum continuation"
                armSlot(i, d, nm, how)
            else if bar_index - brBar.get(i) >= fvgK
                box.delete(cBox.get(i))
                cBox.set(i, na)
                resolveSlot(i)

        // ---- ARMED: wait for swing confirmation, then draw the 50%
        else if s == 3
            L = lv.get(i)
            newExt = d > 0 ? high > ext.get(i) : low < ext.get(i)
            if newExt
                ext.set(i, d > 0 ? high : low)
                extAge.set(i, 0)
            else
                extAge.set(i, extAge.get(i) + 1)
            failedBack = d > 0 ? close < L : close > L
            if failedBack or bar_index - brBar.get(i) > toBars
                if failedBack
                    label.new(bar_index, d > 0 ? low : high, "✗", style = label.style_label_center,
                         color = color.new(color.gray, 70), textcolor = color.silver, size = size.tiny)
                resolveSlot(i)
            else if bar_index > brBar.get(i) and (d > 0 ? low <= L + retestT * syminfo.mintick : high >= L - retestT * syminfo.mintick)
                // Immediate kiss-back: price returned to the broken level while the leg builds
                label.new(bar_index, L, "RETEST " + nm,
                     style = d > 0 ? label.style_label_up : label.style_label_down,
                     color = color.new(color.orange, 30), textcolor = color.white, size = size.small)
                if alRetest
                    alert("B&R RETEST: " + syminfo.ticker + " " + timeframe.period + " " + nm +
                         " immediate retest @ " + str.tostring(L, format.mintick), alert.freq_once_per_bar)
                resolveSlot(i)
            else if extAge.get(i) >= swingN
                mid = (anch.get(i) + ext.get(i)) / 2.0
                f50.set(i, mid)
                line.delete(l50.get(i))
                if show50
                    l50.set(i, line.new(brBar.get(i), mid, bar_index + 10, mid,
                         color = color.new(color.orange, 30), style = line.style_dotted, width = 1))
                st.set(i, 4)

        // ---- AWAIT RETEST: touch of 50% or level, whichever is reached first
        else if s == 4
            L = lv.get(i)
            mid = f50.get(i)
            trigger = d > 0 ? math.max(mid, L) : math.min(mid, L)
            touched = d > 0 ? low <= trigger : high >= trigger
            if touched
                aplus = math.abs(mid - L) <= aplusB
                label.new(bar_index, trigger, "RETEST " + nm + (aplus ? " A+" : ""),
                     style = d > 0 ? label.style_label_up : label.style_label_down,
                     color = color.new(aplus ? color.orange : color.gray, 30), textcolor = color.white, size = size.small)
                if alRetest
                    alert("B&R RETEST: " + syminfo.ticker + " " + timeframe.period + " " + nm +
                         " retest @ " + str.tostring(trigger, format.mintick) +
                         (aplus ? " — A+ (50% = level)" : ""), alert.freq_once_per_bar)
                resolveSlot(i)
            else if (d > 0 ? close < L : close > L) or bar_index - brBar.get(i) > toBars
                resolveSlot(i)

        // ---- LIFETIME SPEND: any close beyond the level consumes its virginity.
        // Evaluated AFTER the state machine so the first break can still arm
        // on its own bar; every subsequent break this lifetime is silent.
        if not na(Llive) and (d > 0 ? close > Llive : close < Llive)
            spent.set(i, true)
````

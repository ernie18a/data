<!-- tradingview-pine-id: PUB;6db6a521810f4ac8b634833657172750 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Acceptance-Retest indicator

Source: https://www.tradingview.com/script/KsBKik8k-Acceptance-Retest-indicator/

## Description

# Acceptance-Retest Dashboard

**Companion to the Sweep-Reclaim Dashboard.** Same four levels, same session logic, opposite
read on price behavior — this one tracks what happens when a level *doesn't* reject.

---

## What this script does

Most level-based tools only handle one outcome: price hits a level and reverses. But price at
a key level only ever does one of three things — **rejects, accepts, or chops** — and a
rejection-only tool is blind to two-thirds of that.

This script tracks the **acceptance** case: a level breaks, price *holds* beyond it instead of
snapping back, and a genuine continuation trade sets up on the retest or base that follows.

It automatically:
- Plots **PDH / PDL / ONH / ONL** — prior-day high/low and overnight high/low
- Detects a real breakout close (not just a wick) beyond any of the four levels
- Confirms the level actually held before treating it as a trade candidate
- Waits for a retest or a tight base to form, then triggers on the break of that structure
- Computes entry, stop, target and R:R automatically — no manual level math
- Tracks the trade live once triggered — active, target hit, stopped, or timed out — so you
  always know whether the last signal is still good
- Fires a TradingView alert the moment a valid setup completes

Every signal on the chart is prefixed **`AR:`** so it's never confused with a rejection-style
signal from a different tool running on the same chart.

---

## The rule book — Acceptance-Retest methodology

### The core idea

At any key level, price does one of three things:

| Behavior | Candle signature | What it means |
|---|---|---|
| **Rejection** | Wick through, closes back inside | Liquidity grab — level held |
| **Acceptance** | Real body close beyond, price holds | Level flipped — trade the hold |
| **Chop** | Repeated wicks and closes both sides | No edge — stand aside |

This script exists for the middle row. If you're already running a rejection/sweep-style
system, this is built to sit alongside it, not replace it — they read the *same* event and
reach opposite, mutually exclusive conclusions from it.

### The sequence, step by step

**1. Breakout.** Price trades through one of the four levels.

**2. Close confirmation.** A candle **closes** beyond the level — a real body close, not a
wick poking through. No close beyond → not this setup.

**3. No-reclaim check.** The next couple of candles must **not** close back on the original
side. If price reclaims within that window, this was a rejection, not an acceptance — a
different setup entirely, and this script drops it.

**4. Hold — retest or base.** Once the no-reclaim check passes, price needs to show one of two
structures before an entry is considered:
   - **Retest:** a pullback toward the level that holds and turns, forming a higher low
     (bullish) or lower high (bearish).
   - **Base:** a tight, low-overlap sideways range instead of a pullback — still evidence the
     level is holding, just without giving a clean retest.

If neither forms within a reasonable window, the attempt expires. Extended, un-based moves are
not entries — they're skips.

**5. Entry.** The break of the retest high/low, or the break of the base range.

**6. Stop.** Beyond the retest or base structure point — never an arbitrary distance, and
capped relative to that level's typical range so a single trade can't take on outsized risk
just because the structural point happened to be far away.

**7. Target.** A measured-move projection from the breakout level, pulled in to the nearer
opposing level when one exists inside that projection.

**8. Filter.** Minimum reward-to-risk gate — trades that don't clear it are skipped, not taken
anyway at reduced size.

### What invalidates a setup after it's already tracking

- **A reclose back through the level** during the hold phase — the move never actually held.
- **No retest or base within the watch window** — extended without structure.
- **Stop distance beyond the risk cap** — the structural stop doesn't fit, so the trade is
  skipped rather than resized to fit.
- **Outside the trading window** — signals outside the configured session are not taken.

### Managing an active signal

Every valid trigger is tracked automatically against three outcomes, all defined *before*
entry, never adjusted mid-trade:

1. **Target hit** — the projected level is reached.
2. **Stop hit** — price trades back through the structural stop.
3. **Time stop** — not resolved by a configured cutoff time, closed out regardless of where
   price is at that moment. A trade that hasn't reached target isn't a trade still "working" —
   it's a trade that should be closed and logged honestly.

A trade that runs *past* target after a time stop already closed it doesn't get to become a
retroactive winner. The discipline is the point — not squeezing the best possible outcome out
of hindsight.

---

## Dashboard guide

**Level rows (PDH / PDL / ONH / ONL):**
- **Price** — the level's current value
- **Stage** — idle, no-reclaim check, or watching for retest/base
- **Bars** — how long the current stage has been running
- **Last signal** — the most recent outcome for that level: a full trade, or a specific skip
  reason (reclaimed, expired, stop beyond cap, R:R too low)

**Active trade row:**
- The single most recent valid signal, with entry / stop / target
- **Status** — ACTIVE, TARGET HIT, STOPPED, or EXPIRED, updated live every bar

A level clustered too close to another active level is marked accordingly and excluded from
detection until it separates — this prevents two overlapping levels from generating
contradictory signals at effectively the same price.

---

## Settings

- **Sessions** — must match your other level-based indicators exactly, or the four levels will
  disagree across scripts on the same chart.
- **Planning** — ATR length, minimum R:R, and the stop-risk cap (scaled to both the level's
  typical range and current volatility, so a calm prior session doesn't choke off signals on a
  day that's actually moving hard).
- **Acceptance rules** — how many bars must pass without a reclaim, how long to wait for a
  retest/base before giving up, and how tight a base range needs to be to count.
- **Trading windows** — the session(s) during which new signals are allowed to trigger.
- **Time stop** — the cutoff time for closing anything still open.
- **Display** — dashboard position, text size, and whether to draw the level lines and active
  trade markers on the chart.

---

## Notes

- This script draws its own copy of PDH/PDL/ONH/ONL so it works standalone; running it
  alongside a companion rejection-style script on the same chart is fully supported — the
  level math is identical, so both agree on where the four levels sit.
- Designed for 5-minute charts on index futures and related instruments; behavior on other
  timeframes or asset classes has not been validated.
- A single active-trade slot is tracked at a time. A new valid signal replaces the previous
  one rather than stacking multiple simultaneous trades.

---

## Disclaimer

This script is a **decision-support and rule-automation tool**, not a signal service or
trading advice. It mechanizes a specific discretionary methodology — it does not predict
price, guarantee outcomes, or account for news, liquidity conditions, or market regime shifts.
Past behavior of any setup shown here is not indicative of future results. All trading
decisions, position sizing, and risk management remain the sole responsibility of the user.
Backtest and forward-test thoroughly before applying any setup with real capital.

---

## Source Code

````pine
//@version=6
// Acceptance-Retest Dashboard - QQQ/NQ 5m
// Companion to Acceptance_Retest_Method.md — the Phase 1B complement to your
// Sweep-Reclaim Dashboard. Session/level/cluster block is lifted verbatim from
// SweepReclaimBugFixV2 so both scripts always agree on PDH/PDL/ONH/ONL.
//
// Logic per level, per method doc:
//   1. Breakout        - price trades through the level
//   2. Close confirm    - a bar CLOSES beyond it (displacement, not a wick)
//   3. No-reclaim check - next N bars must NOT close back on the original side
//                         (if they do, it's a Sweep-Reclaim, not this setup - abandoned here)
//   4. Retest / Base    - wait for a pullback that holds (retest) or a tight
//                         consolidation (base) beyond the level
//   5. Entry             - break of the retest high/low or base high/low
//   6. Stop               - beyond the retest/base structure point, capped at
//                         (level range / stopCapDiv)
//   7. Target            - measured move (level +/- level range), or the
//                         nearer opposing level if one sits inside that projection
//   Filter: R:R >= minRR or skip. Single active-trade slot, like your existing
//   SweepReclaim_Draw_EntryExitSL script - a new trigger replaces the last one.

indicator("Acceptance-Retest indicator", "AR Dash", overlay = true, max_lines_count = 100, max_labels_count = 200)

// ─────────────────────────────────────────────────────────── inputs

gS = "Sessions"
tzi     = input.string("America/New_York", "Time zone", options = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "UTC", "Europe/London", "Europe/Bucharest", "Asia/Kolkata"], group = gS)
rthSess = input.session("0930-1600", "RTH session (PDH/PDL)", group = gS)
onSess  = input.session("1600-0925", "Overnight session (ONH/ONL)", group = gS)
rthDays = input.string("1234567", "Session days (1=Sun ... 7=Sat)", group = gS, tooltip = "Must match your Sweep-Reclaim script and your PDH/PDL/ONH/ONL indicator exactly - same levels feed both setups.")

gP = "Planning"
atrLen     = input.int(14, "ATR length", minval = 2, group = gP)
clusterPct = input.float(0.05, "Cluster tolerance (%)", minval = 0.0, step = 0.01, group = gP)
clusterT   = close * clusterPct / 100.0
minRR      = input.float(1.5, "Minimum R:R", minval = 1.0, step = 0.1, group = gP, tooltip = "Same 1.5 filter as Sweep-Reclaim's box-ratio rule.")
stopCapDiv = input.float(1.5, "Stop cap divisor (level range / X)", minval = 1.0, step = 0.1, group = gP, tooltip = "Structural stop must fit inside (cap basis / X). If the retest/base point sits beyond this, the trade is skipped, not resized.")
atrCapMult = input.float(1.3, "ATR cap multiplier", minval = 0.5, step = 0.1, group = gP, tooltip = "Cap basis = min(level range, ATR x this). Prevents a calm prior session's level range from choking off every signal on a day that's actually running much more volatile than yesterday (e.g. today's ATR >> level range).")

gR = "Acceptance rules"
noReclaimBars = input.int(2, "No-reclaim check (bars)", minval = 1, maxval = 5, group = gR, tooltip = "Bars after the displacement close that must NOT close back on the original side. A reclose here hands the move to Sweep-Reclaim instead.")
maxWatchBars  = input.int(6, "Max bars to wait for retest/base", minval = 2, maxval = 20, group = gR, tooltip = "If neither structure forms in this many bars, the attempt expires - 'extended without a base', per the doc.")
minBaseBars   = input.int(2, "Min bars for a valid base", minval = 2, maxval = 10, group = gR)
baseATRmult   = input.float(0.5, "Max base range (x ATR)", minval = 0.1, step = 0.1, group = gR, tooltip = "A rolling range this tight or tighter, held for Min bars, counts as a base.")
bufPct        = input.float(0.05, "Stop buffer (%)", minval = 0.0, step = 0.01, group = gR)

gW = "Trading windows"
w1 = input.session("0930-1130", "Morning window", group = gW)
w2 = input.session("1400-1530", "Afternoon window", group = gW)

gT = "Time stop"
timeStopH = input.int(12, "Time-stop hour", minval = 0, maxval = 23, group = gT)
timeStopM = input.int(0, "Time-stop minute", minval = 0, maxval = 59, group = gT)

gA = "Alerts"
alertSetups = input.bool(true, "Alert on valid setups", group = gA)

gD = "Display"
showTable = input.bool(true, "Show dashboard", group = gD)
showLines = input.bool(true, "Draw levels", group = gD)
showTrade = input.bool(true, "Draw active trade lines", group = gD)
tblPos    = input.string("Bottom right", "Dashboard position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gD)
txtSizeIn = input.string("Normal", "Text size", options = ["Small", "Normal", "Large", "Huge"], group = gD)
txtSize   = txtSizeIn == "Small" ? size.small : txtSizeIn == "Normal" ? size.normal : txtSizeIn == "Large" ? size.large : size.huge

// ─────────────────────────────────────────────────────────── sessions and levels
// ══════ Verbatim from the Sweep-Reclaim script. Do not "improve" it - both
// scripts must compute identical PDH/PDL/ONH/ONL or the two setups will disagree.

rthIn = not na(time(timeframe.period, rthSess + ":" + rthDays, tzi))
onIn  = not na(time(timeframe.period, onSess  + ":" + rthDays, tzi))

var bool rthWas = false
var bool onWas  = false

var float rthHi = na
var float rthLo = na
var float onHi  = na
var float onLo  = na

var float pdh = na
var float pdl = na
var float onh = na
var float onl = na

if rthIn
    bool fresh = not rthWas or na(rthHi)
    if fresh or high > rthHi
        rthHi := high
    if fresh or low < rthLo
        rthLo := low
rthEnd = rthWas and not rthIn

if onIn
    bool freshOn = not onWas or na(onHi)
    if freshOn or high > onHi
        onHi := high
    if freshOn or low < onLo
        onLo := low
onEnd = onWas and not onIn

if rthEnd
    pdh := rthHi
    pdl := rthLo
    rthHi := na
    rthLo := na

if onEnd
    onh := onHi
    onl := onLo
    onHi := na
    onLo := na

// ══════ end of imported logic ══════

inRTH  = rthIn
newRTH = rthIn and not rthWas

onhLive = na(onHi) ? onh : onHi
onlLive = na(onLo) ? onl : onLo
onhShow = onhLive
onlShow = onlLive

atrNow = ta.atr(atrLen)

// ─────────────────────────────────────────────────────────── cluster check (verbatim pattern)

hiClust = not na(pdh) and not na(onhShow) and math.abs(onhShow - pdh) <= clusterT
loClust = not na(pdl) and not na(onlShow) and math.abs(onlShow - pdl) <= clusterT

act0 = not (hiClust and pdh < onhShow)
act1 = not (loClust and pdl > onlShow)
act2 = not (hiClust and onhShow < pdh)
act3 = not (loClust and onlShow > pdl)

prices  = array.from(pdh, pdl, onhShow, onlShow)
actives = array.from(act0, act1, act2, act3)
var names = array.from("PDH", "PDL", "ONH", "ONL")

// Level range each price belongs to, for the stop cap + measured-move target.
// PDH/PDL share the RTH range; ONH/ONL share the overnight range.
pdRange = (na(pdh) or na(pdl)) ? na : math.abs(pdh - pdl)
onRange = (na(onhShow) or na(onlShow)) ? na : math.abs(onhShow - onlShow)
levelRanges = array.from(pdRange, pdRange, onRange, onRange)

inW = (not na(time(timeframe.period, w1, tzi))) or (not na(time(timeframe.period, w2, tzi)))
buf = close * bufPct / 100.0

nowH = hour(time, tzi)
nowM = minute(time, tzi)
pastTimeStop = (nowH > timeStopH) or (nowH == timeStopH and nowM >= timeStopM)

// ─────────────────────────────────────────────────────────── per-level state

var arActive   = array.new_bool(4, false)
var arDir      = array.new_int(4, 0)     // 1 = long attempt, -1 = short attempt
var arStage    = array.new_int(4, 0)     // 1 = no-reclaim check, 2 = watching retest/base
var arCheck    = array.new_int(4, 0)
var arWatch    = array.new_int(4, 0)
var arPullExt  = array.new_float(4, na)  // retest candidate: lowest low (long) / highest high (short)
var arRecov    = array.new_float(4, na)  // recovery high (long) / recovery low (short) after the pull extreme
var arBaseHi   = array.new_float(4, na)
var arBaseLo   = array.new_float(4, na)
var arBaseBars = array.new_int(4, 0)
var lastLvlSig = array.new_string(4, "-")
var lastLvlCol = array.new_color(4, color.gray)

if newRTH
    for i = 0 to 3
        array.set(arActive, i, false)
        array.set(arStage, i, 0)
        array.set(lastLvlSig, i, "-")
        array.set(lastLvlCol, i, color.gray)

// Single active-trade slot - same limitation as SweepReclaim_Draw_EntryExitSL.
var int    actDir    = 0
var float  actEntry  = na
var float  actStop   = na
var float  actTgt    = na
var string actLevel  = ""
var string actStruct = ""
var string actStatus = ""   // "ACTIVE" / "TARGET HIT" / "STOPPED" / "EXPIRED"
var color  actColor  = color.gray
var line   entryLn = na
var line   stopLn  = na
var line   tgtLn   = na
var label  actLbl  = na

bool fired = false
string alertMsg = ""

// ─────────────────────────────────────────────────────────── detection

if barstate.isconfirmed
    for i = 0 to 3
        L  = array.get(prices, i)
        lr = array.get(levelRanges, i)
        if not na(L) and array.get(actives, i)

            if not array.get(arActive, i)
                // Step 1+2: breakout with a real close beyond the level (displacement)
                longDispl  = close[1] <= L and close > L
                shortDispl = close[1] >= L and close < L
                if (longDispl or shortDispl) and inW
                    array.set(arActive, i, true)
                    array.set(arDir, i, longDispl ? 1 : -1)
                    array.set(arStage, i, 1)
                    array.set(arCheck, i, 0)
                    array.set(arPullExt, i, na)
                    array.set(arRecov, i, na)
                    array.set(arBaseHi, i, high)
                    array.set(arBaseLo, i, low)
                    array.set(arBaseBars, i, 0)

            else
                dir     = array.get(arDir, i)
                stage   = array.get(arStage, i)
                reclosed = dir == 1 ? close <= L : close >= L

                if stage == 1
                    // Step 3: no-reclaim check
                    if reclosed
                        array.set(arActive, i, false)
                        array.set(lastLvlSig, i, "reclaimed - handed to Sweep-Reclaim")
                        array.set(lastLvlCol, i, color.gray)
                    else
                        array.set(arCheck, i, array.get(arCheck, i) + 1)
                        if array.get(arCheck, i) >= noReclaimBars
                            array.set(arStage, i, 2)
                            array.set(arWatch, i, 0)
                            array.set(arPullExt, i, dir == 1 ? low : high)
                            array.set(arRecov, i, dir == 1 ? high : low)
                            array.set(arBaseHi, i, high)
                            array.set(arBaseLo, i, low)
                            array.set(arBaseBars, i, 1)

                else if stage == 2
                    // Step 4: watch for retest or base; abandon on a reclose
                    if reclosed
                        array.set(arActive, i, false)
                        array.set(lastLvlSig, i, "held broke - reclaimed after hold")
                        array.set(lastLvlCol, i, color.gray)
                    else
                        array.set(arWatch, i, array.get(arWatch, i) + 1)

                        // Use the structure established BEFORE this bar. A retest/base
                        // breakout has to clear a frontier set by prior bars - checking
                        // against a frontier that already includes this bar's own high/low
                        // makes the breakout mathematically unreachable (a close can never
                        // exceed its own bar's high). Update the frontier AFTER the check,
                        // and only if this bar didn't trigger.
                        pullExt  = array.get(arPullExt, i)
                        recov    = array.get(arRecov, i)
                        baseHiP  = array.get(arBaseHi, i)
                        baseLoP  = array.get(arBaseLo, i)
                        baseBarsP = array.get(arBaseBars, i)
                        baseRangeP = baseHiP - baseLoP
                        baseOK   = baseRangeP <= baseATRmult * atrNow and baseBarsP >= minBaseBars

                        retestEntryLong  = dir == 1 and not na(recov) and close > recov
                        retestEntryShort = dir == -1 and not na(recov) and close < recov
                        baseEntryLong    = dir == 1 and baseOK and close > baseHiP
                        baseEntryShort   = dir == -1 and baseOK and close < baseLoP

                        triggered = retestEntryLong or retestEntryShort or baseEntryLong or baseEntryShort
                        structTxt = (retestEntryLong or retestEntryShort) ? "retest" : "base"

                        if triggered
                            entry = close
                            float stop = na
                            if structTxt == "retest"
                                stop := dir == 1 ? pullExt - buf : pullExt + buf
                            else
                                stop := dir == 1 ? baseLoP - buf : baseHiP + buf

                            risk = math.abs(entry - stop)
                            capBasis = na(lr) ? atrNow * atrCapMult : math.max(lr, atrNow * atrCapMult)
                            cap  = na(capBasis) ? na : capBasis / stopCapDiv
                            okCap = not na(cap) and risk <= cap

                            mm = L + dir * lr  // measured-move target
                            float tgt = mm
                            for j = 0 to 3
                                p = array.get(prices, j)
                                if not na(p) and array.get(actives, j) and j != i
                                    if dir == 1 and p > L and p < mm
                                        tgt := math.min(tgt, p)
                                    if dir == -1 and p < L and p > mm
                                        tgt := math.max(tgt, p)

                            reward = math.abs(tgt - entry)
                            rr     = risk <= 0 ? na : reward / risk
                            okRR   = not na(rr) and rr >= minRR
                            valid  = okCap and okRR and inW

                            side = dir == 1 ? "LONG" : "SHORT"
                            nm   = array.get(names, i)

                            if valid
                                sigTxt = side + " " + nm + " (" + structTxt + ")  entry " + str.tostring(entry, "#.##") + "  stop " + str.tostring(stop, "#.##") + "  tgt " + str.tostring(tgt, "#.##") + "  " + str.tostring(rr, "#.##") + "R"
                                sigCol = dir == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
                                array.set(lastLvlSig, i, sigTxt)
                                array.set(lastLvlCol, i, sigCol)

                                actDir    := dir
                                actEntry  := entry
                                actStop   := stop
                                actTgt    := tgt
                                actLevel  := nm
                                actStruct := structTxt
                                actStatus := "ACTIVE"
                                actColor  := sigCol

                                fired    := true
                                alertMsg := "AR: ACCEPTANCE-RETEST " + side + " " + nm + " (" + structTxt + ")\n" + "Entry " + str.tostring(entry, "#.##") + " | Stop " + str.tostring(stop, "#.##") + " | Risk " + str.tostring(risk, "#.##") + "\n" + "Target " + str.tostring(tgt, "#.##") + " (" + str.tostring(rr, "#.##") + "R)"

                                label.new(bar_index, dir == 1 ? low : high, "AR: " + side + " " + nm + "\n" + structTxt + " " + str.tostring(rr, "#.##") + "R", style = dir == 1 ? label.style_label_up : label.style_label_down, color = sigCol, textcolor = color.white, size = size.normal)
                            else
                                reason = not okCap ? "stop beyond cap" : not okRR ? "R:R " + (na(rr) ? "no target" : str.tostring(rr, "#.##")) : "outside window"
                                array.set(lastLvlSig, i, "SKIP " + side + " " + nm + " (" + structTxt + ") - " + reason)
                                array.set(lastLvlCol, i, color.gray)

                            array.set(arActive, i, false)

                        else
                            // No trigger this bar - fold this bar's high/low into the
                            // frontier so the NEXT bar has to clear a higher/lower bar.
                            if dir == 1
                                if na(pullExt) or low < pullExt
                                    array.set(arPullExt, i, low)
                                    array.set(arRecov, i, high)
                                else
                                    array.set(arRecov, i, math.max(recov, high))
                            else
                                if na(pullExt) or high > pullExt
                                    array.set(arPullExt, i, high)
                                    array.set(arRecov, i, low)
                                else
                                    array.set(arRecov, i, math.min(recov, low))

                            array.set(arBaseHi, i, math.max(baseHiP, high))
                            array.set(arBaseLo, i, math.min(baseLoP, low))
                            array.set(arBaseBars, i, baseBarsP + 1)

                            if array.get(arWatch, i) >= maxWatchBars
                                array.set(arActive, i, false)
                                array.set(lastLvlSig, i, "expired - no retest/base formed")
                                array.set(lastLvlCol, i, color.gray)

if fired and alertSetups
    alert(alertMsg, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────── active-trade monitor (still valid?)

var int resolvedBar = na

if barstate.isconfirmed and actStatus == "ACTIVE"
    prevStatus = actStatus
    if actDir == 1
        if low <= actStop
            actStatus := "STOPPED"
        else if high >= actTgt
            actStatus := "TARGET HIT"
        else if pastTimeStop
            actStatus := "EXPIRED (time stop)"
    else if actDir == -1
        if high >= actStop
            actStatus := "STOPPED"
        else if low <= actTgt
            actStatus := "TARGET HIT"
        else if pastTimeStop
            actStatus := "EXPIRED (time stop)"
    if actStatus != prevStatus
        resolvedBar := bar_index

// Clear the trade slot at the start of a new overnight session, same as the level reset.
if newRTH
    actStatus := ""
    actDir := 0
    resolvedBar := na

// ─────────────────────────────────────────────────────────── active-trade lines

if showTrade and actStatus != "" and not na(actEntry) and (actStatus == "ACTIVE" or bar_index == resolvedBar)
    line.delete(entryLn)
    line.delete(stopLn)
    line.delete(tgtLn)
    label.delete(actLbl)
    lineCol = actStatus == "ACTIVE" ? color.new(color.blue, 0) : actStatus == "TARGET HIT" ? color.new(color.green, 0) : actStatus == "STOPPED" ? color.new(color.red, 0) : color.new(color.gray, 40)
    x2 = actStatus == "ACTIVE" ? bar_index + 5 : bar_index + 2
    entryLn := line.new(bar_index - 20, actEntry, x2, actEntry, color = lineCol, style = line.style_solid, width = 1)
    stopLn  := line.new(bar_index - 20, actStop,  x2, actStop,  color = color.new(color.red, 30), style = line.style_dashed, width = 1)
    tgtLn   := line.new(bar_index - 20, actTgt,   x2, actTgt,   color = color.new(color.green, 30), style = line.style_dashed, width = 1)
    actLbl  := label.new(x2, actEntry, "AR: " + actLevel + " " + actStruct + " " + actStatus, style = label.style_label_left, color = lineCol, textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────────────────── plots

plot(showLines and not na(pdh) ? pdh : na, "PDH", color.new(color.red, 0), 1, plot.style_linebr)
plot(showLines and not na(pdl) ? pdl : na, "PDL", color.new(color.green, 0), 1, plot.style_linebr)
plot(showLines and not na(onhShow) ? onhShow : na, "ONH", color.new(color.orange, 0), 1, plot.style_linebr)
plot(showLines and not na(onlShow) ? onlShow : na, "ONL", color.new(color.blue, 0), 1, plot.style_linebr)

// ─────────────────────────────────────────────────────────── dashboard

pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : position.middle_right

var table dash = table.new(pos, 6, 7, border_width = 1)

stageTxt(int st) =>
    st == 0 ? "idle" : st == 1 ? "no-reclaim chk" : st == 2 ? "watch retest/base" : "-"

if showTable and barstate.islast
    bg  = color.new(color.gray, 90)
    hbg = color.new(color.gray, 70)
    tc  = chart.fg_color

    table.cell(dash, 0, 0, "Level", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 0, "Price", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 0, "Stage", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 0, "Bars", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 4, 0, "Last signal", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.merge_cells(dash, 4, 0, 5, 0)

    for i = 0 to 3
        r = i + 1
        L = array.get(prices, i)
        a = array.get(actives, i)
        st = array.get(arStage, i)
        table.cell(dash, 0, r, array.get(names, i), bgcolor = bg, text_color = tc, text_size = txtSize)
        table.cell(dash, 1, r, na(L) ? "-" : str.tostring(L, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
        table.cell(dash, 2, r, na(L) ? "-" : (a ? stageTxt(array.get(arActive, i) ? st : 0) : "clustered"), bgcolor = bg, text_color = tc, text_size = txtSize)
        barsShown = st == 1 ? array.get(arCheck, i) : st == 2 ? array.get(arWatch, i) : 0
        table.cell(dash, 3, r, na(L) or not array.get(arActive, i) ? "-" : str.tostring(barsShown), bgcolor = bg, text_color = tc, text_size = txtSize)
        table.cell(dash, 4, r, array.get(lastLvlSig, i), bgcolor = bg, text_color = array.get(lastLvlCol, i), text_size = txtSize)
        table.merge_cells(dash, 4, r, 5, r)

    table.cell(dash, 0, 5, "Active trade", bgcolor = hbg, text_color = tc, text_size = txtSize)
    tradeTxt = actStatus == "" ? "none" : actLevel + " " + (actDir == 1 ? "LONG" : "SHORT") + " (" + actStruct + ")  E " + str.tostring(actEntry, "#.##") + " S " + str.tostring(actStop, "#.##") + " T " + str.tostring(actTgt, "#.##")
    table.cell(dash, 1, 5, tradeTxt, bgcolor = bg, text_color = actColor, text_size = txtSize)
    table.merge_cells(dash, 1, 5, 5, 5)

    table.cell(dash, 0, 6, "Status", bgcolor = hbg, text_color = tc, text_size = txtSize)
    statCol = actStatus == "ACTIVE" ? color.new(color.blue, 0) : actStatus == "TARGET HIT" ? color.new(color.green, 0) : actStatus == "STOPPED" ? color.new(color.red, 0) : color.new(color.gray, 0)
    table.cell(dash, 1, 6, actStatus == "" ? "-" : actStatus, bgcolor = bg, text_color = statCol, text_size = txtSize)
    table.cell(dash, 2, 6, "Window", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 6, inW ? "OPEN" : "closed", bgcolor = bg, text_color = inW ? color.new(color.green, 0) : color.new(color.gray, 0), text_size = txtSize)
    table.cell(dash, 4, 6, "ON", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 5, 6, inRTH ? "final" : "live", bgcolor = bg, text_color = inRTH ? tc : color.new(color.orange, 0), text_size = txtSize)

// Must be last: holds the PREVIOUS bar's session state for everything above.
rthWas := rthIn
onWas  := onIn
````

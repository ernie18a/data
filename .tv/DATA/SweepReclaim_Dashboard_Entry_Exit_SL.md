<!-- tradingview-pine-id: PUB;3800d0eae7c9431a81977b62617462a7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sweep-Reclaim Dashboard Entry Exit SL

Source: https://www.tradingview.com/script/mYbTpDQ1-Sweep-Reclaim-Dashboard-Entry-Alert/

## Description

Sweep-Reclaim Dashboard tracks four key intraday levels — prior-day high (PDH),
prior-day low (PDL), overnight high (ONH), and overnight low (ONL) — and flags
only the specific failed-breakout pattern this script is built around: price
sweeps through one of these levels and then reclaims it (closes back on the
original side) within a limited number of bars, without accepting beyond it.

WHAT IT DOES

Pre-market: builds PDH/PDL from the regular session and ONH/ONL from the
overnight session, checks whether any two levels sit too close together to be
treated as separate zones ("clustered"), and estimates a stop distance from the
previous day's ATR.

Live: watches each active level for a sweep, then runs every reclaim through
five hard rules before calling it valid:
  1. Closes beyond the level did not exceed the configured maximum (more than
     that is acceptance, not a sweep, and the setup is dead).
  2. Price reclaimed the level within the configured max bar count.
  3. Sweep depth fell between a configurable minimum (filters out noise/brushes)
     and maximum (filters out sweeps that are actually breakouts).
  4. The reclaim bar's close sits deep enough into its own range (a
     configurable top/bottom fraction) to show real rejection, not a weak wick.
  5. Candle color matches the trade direction, if that filter is enabled.

Valid signals also have to fall inside one of two configurable trading windows
and clear a minimum reward:risk versus the nearest opposing level (which is
used as the target). Only then does the script plot a signal label with entry,
stop, target, and R-multiple, and optionally fire an alert.

DASHBOARD

Toggle between two dashboard modes:
- Inputs only: shows the raw levels, previous-day ATR, the ATR-based stop
  estimate, current price, and whether price is inside the overnight range —
  deliberately does NOT compute direction or R:R for you, if you want to keep
  doing that step by hand.
- Full table: computes direction, target, distance, expected R:R, and a
  watch/skip verdict for every active level in real time, plus a running list
  of any level currently mid-sweep.

A "Study mode" hides close-counts and rule verdicts so you can practice reading
the setups yourself before letting the script confirm them. A "Debug row" shows
the script's raw internal session/level state, useful for verifying it agrees
with any separate PDH/PDL/ONH/ONL reference indicator on your chart.

VISUAL RISK BOXES

Every valid signal draws an entry line, a stop-loss line, and one or two
target lines (T1 at 2R, T2 at the nearest non-swept opposing level), plus
shaded green/red zones showing the profit and loss areas at a glance. Lines
and zones auto-extend to the right while the trade is still open, and each
line/label turns green with a checkmark when its target is hit, or red with
an X when the stop is hit — so you can see how a signal actually played out
without leaving the chart. Only the most recent signal's box is shown at a
time. Box length, colors, and fills are all configurable.

ALERTS

One configurable pre-market "plan" alert per day listing each active level,
direction, target, and estimated R from the ATR-based stop estimate — and one
alert per valid live signal, if enabled.

NOTES

- The live target/R:R math for a signal excludes any opposing level that has
  already been swept during the session; the once-daily plan alert message
  does not apply that exclusion, so the two can point at different levels
  mid-session — check the live dashboard/signal for the level actually being
  traded.
- Originally built and tuned against QQQ on a 5-minute chart. Threshold inputs
  (cluster tolerance, sweep depth, stop multiplier) are percentage-of-price
  based so they scale across instruments, but re-validate the defaults before
  relying on this for other symbols or timeframes.
- This is a decision-support indicator, not an auto-trading strategy: it does
  not place orders and carries no backtest/win-rate claims. All signals require
  the trader's own risk management and judgment.
- The four session inputs (time zone, RTH session, overnight session, session
  days) must match any separate PDH/PDL/ONH/ONL indicator on your chart
  exactly, or the two will disagree.

This script is provided for educational and informational purposes. It is not
financial advice, and past patterns matching these rules do not guarantee
future results.

---

## Source Code

````pine
//@version=6
// Sweep-Reclaim Dashboard - QQQ 5m
// Companion to sweep-reclaim-spec-qqq-5m.md and premarket-routine-sweep-reclaim.md
//
// Pre-market: computes PDH/PDL/ONH/ONL, cluster check, direction, targets,
//             estimated stop, expected R per level, TRADE/SKIP verdict.
// Live:       tracks sweeps, counts closes beyond, detects reclaims, checks all
//             five hard rules, computes entry / stop / T1 / T2 / R:R.
// Alerts:     one plan alert at a configured time, plus valid-setup alerts.

indicator("Sweep-Reclaim Dashboard Entry Exit SL", "SR EnExSL", overlay = true, max_lines_count = 100, max_labels_count = 200)

// ─────────────────────────────────────────────────────────── inputs

gS = "Sessions"
tzi     = input.string("America/New_York", "Time zone", options = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "UTC", "Europe/London", "Europe/Bucharest", "Asia/Kolkata"], group = gS)
rthSess = input.session("0930-1600", "RTH session (PDH/PDL)", group = gS)
onSess  = input.session("1600-0925", "Overnight session (ONH/ONL)", group = gS)
rthDays = input.string("1234567", "Session days (1=Sun ... 7=Sat)", group = gS, tooltip = "These four inputs must match your PDH/PDL/ONH/ONL indicator exactly. Same logic, same settings, same numbers.")

gP = "Planning"
atrLen   = input.int(14, "ATR length", minval = 2, group = gP, tooltip = "Read from the previous regular session's final bar - the same number the manual routine has you take off yesterday's 15:55 candle.")
sMult    = input.float(1.3, "Stop estimate multiplier", minval = 0.5, step = 0.1, group = gP)
clusterPct = input.float(0.05, "Cluster tolerance (%)", minval = 0.0, step = 0.01, group = gP, tooltip = "Levels closer together than this merge into one zone; only the outer edge stays tradeable. Percentage rather than points so it scales across instruments - 0.05% is ~0.27 on QQQ at 530 and ~12.5 on NQ at 25000.")
clusterT   = close * clusterPct / 100.0
minRR    = input.float(2.0, "Minimum R:R", minval = 1.0, step = 0.1, group = gP)

gR = "Hard rules"
maxCloses = input.int(1, "Max closes beyond level", minval = 0, maxval = 3, group = gR, tooltip = "2 or more = acceptance. Setup dead.")
maxBars   = input.int(3, "Max bars to reclaim", minval = 1, group = gR)
maxDepth  = input.float(0.35, "Max sweep depth (%)", minval = 0.05, step = 0.05, group = gR)
minDepth  = input.float(0.03, "Min sweep depth (%)", minval = 0.0, step = 0.01, group = gR, tooltip = "NOT in the written spec - added here because code needs a number where the spec says 'eyeball it'. 0.03% is about 16c on QQQ at 530. Tune it.")
thirdThr  = input.float(0.66, "Reclaim close in top/bottom fraction", minval = 0.5, maxval = 0.95, step = 0.01, group = gR)
needColor = input.bool(true, "Require correct candle colour", group = gR, tooltip = "Green for a long, red for a short.")
bufPct    = input.float(0.05, "Stop buffer (%)", minval = 0.0, step = 0.01, group = gR)

gW = "Trading windows"
w1 = input.session("0930-1130", "Morning window", group = gW)
w2 = input.session("1400-1530", "Afternoon window", group = gW)

gA = "Alerts"
planHour    = input.int(9, "Plan alert hour", minval = 0, maxval = 23, group = gA)
planMin     = input.int(15, "Plan alert minute", minval = 0, maxval = 59, group = gA)
alertSetups = input.bool(true, "Alert on valid setups", group = gA)

gD = "Display"
showTable = input.bool(true, "Show dashboard", group = gD)
dispMode  = input.string("Inputs only", "Dashboard mode", options = ["Inputs only", "Full table"], group = gD, tooltip = "Inputs only shows levels, previous-day ATR, S and price - the raw facts, so you still work out direction, targets and expected R yourself. Full table computes everything.")
showLines = input.bool(true, "Draw levels", group = gD)
studyMode = input.bool(false, "Study mode", group = gD, tooltip = "Hides close-counts and rule verdicts so you keep reading the chart yourself. R table still works.")
showDebug = input.bool(false, "Debug row", group = gD, tooltip = "Replaces the Last row with raw session state, so you can see what the script actually thinks the time and levels are.")
tblPos    = input.string("Top right", "Dashboard position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = gD)
txtSizeIn = input.string("Large", "Text size", options = ["Small", "Normal", "Large", "Huge"], group = gD)
txtSize   = txtSizeIn == "Small" ? size.small : txtSizeIn == "Normal" ? size.normal : txtSizeIn == "Large" ? size.large : size.huge

gTR = "Calculation trace"
showTrace = input.bool(false, "Show calculation trace", group = gTR, tooltip = "Second panel showing every number behind the last verdict: pre-market inputs, the sweep candle, the reclaim candle, all six rule checks, the geometry, and the live trade status.")
tracePos  = input.string("Bottom left", "Trace position", options = ["Bottom left", "Bottom right", "Top left", "Middle left", "Middle right"], group = gTR)
trcSizeIn = input.string("Small", "Trace text size", options = ["Tiny", "Small", "Normal"], group = gTR)
trcSize   = trcSizeIn == "Tiny" ? size.tiny : trcSizeIn == "Small" ? size.small : size.normal

gVR = "Visual Risk Boxes"
showVR       = input.bool(true, "Show Entry/SL/TP Boxes", group = gVR, tooltip = "Draws entry/stop/T1/T2 lines plus green profit and red loss zone boxes on each valid signal, and tracks which level gets hit first.")
vrLen        = input.int(20, "Box Length (bars)", minval = 5, group = gVR, tooltip = "How far right the lines/boxes extend before a target or stop is hit. Auto-extends bar by bar while the trade is still open.")
vrTPColor    = input.color(color.aqua, "TP Color", group = gVR)
vrSLColor    = input.color(color.orange, "SL Color", group = gVR)
vrProfitFill = input.color(color.new(color.green, 85), "Profit Fill", group = gVR)
vrLossFill   = input.color(color.new(color.red, 85), "Loss Fill", group = gVR)

// ─────────────────────────────────────────────────────────── sessions and levels

// ══════ Level logic lifted verbatim from PDHLONHL_final.pine. Do not "improve" it.
// Every previous attempt of mine to derive sessions from bar timestamps produced
// levels that disagreed with the chart. This block is the verified version.

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

// Running overnight extremes. Falls back to the finalised value once the session has
// ended and the accumulator is reset, so this is correct at every hour of the day.
onhLive = na(onHi) ? onh : onHi
onlLive = na(onLo) ? onl : onLo

// The MAIN cells carry the live figures, because those are what the 09:15 plan needs.
// The finalised pair - which is what gets drawn on the chart - moves to a secondary row.
// Having it the other way round put the stale number in the prominent position and it
// got transcribed into plans twice.
onhShow = onhLive
onlShow = onlLive

atrNow = ta.atr(atrLen)
var float runATR = na
var float pdATR  = na
if rthEnd
    pdATR := runATR
if rthIn
    runATR := atrNow

S = nz(pdATR) * sMult

// ─────────────────────────────────────────────────────────── cluster check

hiClust = not na(pdh) and not na(onhShow) and math.abs(onhShow - pdh) <= clusterT
loClust = not na(pdl) and not na(onlShow) and math.abs(onlShow - pdl) <= clusterT

act0 = not (hiClust and pdh < onhShow)
act1 = not (loClust and pdl > onlShow)
act2 = not (hiClust and onhShow < pdh)
act3 = not (loClust and onlShow > pdl)

prices  = array.from(pdh, pdl, onhShow, onlShow)
actives = array.from(act0, act1, act2, act3)

var names = array.from("PDH", "PDL", "ONH", "ONL")

// ─────────────────────────────────────────────────────────── state

var swDir   = array.new_int(4, 0)
var swExt   = array.new_float(4, na)
var swClos  = array.new_int(4, 0)
var swBars  = array.new_int(4, 0)
var swept   = array.new_bool(4, false)

if newRTH
    for i = 0 to 3
        array.set(swept, i, false)
        array.set(swDir, i, 0)
        array.set(swClos, i, 0)

inW      = (not na(time(timeframe.period, w1, tzi))) or (not na(time(timeframe.period, w2, tzi)))
buf      = close * bufPct / 100.0
rng      = high - low
posInRng = rng > 0 ? (close - low) / rng : 0.5

// ─────────────────────────────────────────────────────────── detection

var string lastSig  = ""
var color  lastSigC = color.gray
string alertMsg     = ""
bool   fired        = false

// ─────────────────────────────────────────────────────────── visual risk box state
var line  vrLineEntry = na
var line  vrLineSL    = na
var line  vrLineT1    = na
var line  vrLineT2    = na
var label vrLbEntry   = na
var label vrLbSL      = na
var label vrLbT1      = na
var label vrLbT2      = na
var box   vrProfitBox = na
var box   vrLossBox   = na

// ─────────────────────────────────────────────────────────── calculation trace state
// Every input to the last verdict, held so the trace panel can show the working.
var string trcName   = ""
var float  trcLvl    = na
var string trcSide   = ""
var string trcClock  = ""
var float  trcExt    = na
var float  trcDepthA = na
var float  trcDepthP = na
var int    trcCloses = 0
var int    trcBars   = 0
var float  trcO      = na
var float  trcH      = na
var float  trcL      = na
var float  trcC      = na
var float  trcPos    = na
var float  trcEntry  = na
var float  trcStop   = na
var float  trcRisk   = na
var float  trcT1     = na
var float  trcT2     = na
var float  trcRR     = na
var bool   trcOkCl   = false
var bool   trcOkBr   = false
var bool   trcOkDp   = false
var bool   trcOkPs   = false
var bool   trcOkCo   = false
var bool   trcOkTm   = false
var bool   trcOkRR   = false
var bool   trcValid  = false
var string trcReason = ""

var int   vrDir   = 0
var float vrEntry = na
var float vrSL    = na
var float vrT1    = na
var float vrT2    = na
var bool  vrT1Hit = false
var bool  vrT2Hit = false
var bool  vrSLHit = false

for i = 0 to 3
    L = array.get(prices, i)
    if not na(L) and array.get(actives, i) and barstate.isconfirmed
        dir = array.get(swDir, i)

        if dir == 0
            if close[1] < L and high > L
                array.set(swDir, i, 1)
                array.set(swExt, i, high)
                array.set(swBars, i, 0)
                array.set(swClos, i, 0)
                array.set(swept, i, true)
            else if close[1] > L and low < L
                array.set(swDir, i, -1)
                array.set(swExt, i, low)
                array.set(swBars, i, 0)
                array.set(swClos, i, 0)
                array.set(swept, i, true)
        else
            array.set(swBars, i, array.get(swBars, i) + 1)
            array.set(swExt, i, dir == 1 ? math.max(array.get(swExt, i), high) : math.min(array.get(swExt, i), low))

        d = array.get(swDir, i)
        if d != 0
            // A close sitting EXACTLY on the level has not reclaimed anything - it
            // landed on the line. Counted as still-beyond rather than as a reclaim.
            beyond = d == 1 ? close >= L : close <= L

            if beyond
                array.set(swClos, i, array.get(swClos, i) + 1)
                if array.get(swClos, i) > maxCloses or array.get(swBars, i) >= maxBars
                    array.set(swDir, i, 0)
            else
                ext      = array.get(swExt, i)
                nCloses  = array.get(swClos, i)
                nBars    = array.get(swBars, i)
                depthAbs = d == 1 ? ext - L : L - ext
                depthPct = depthAbs / L * 100.0

                okCloses = nCloses <= maxCloses
                okBars   = nBars <= maxBars
                okDepth  = depthPct <= maxDepth and depthPct >= minDepth
                okPos    = d == 1 ? posInRng <= (1.0 - thirdThr) : posInRng >= thirdThr
                okColor  = not needColor or (d == 1 ? close < open : close > open)
                okTime   = inW

                entry = close
                stop  = d == 1 ? ext + buf : ext - buf
                risk  = math.abs(entry - stop)
                t1    = d == 1 ? entry - 2.0 * risk : entry + 2.0 * risk

                float tgt = na
                for j = 0 to 3
                    p = array.get(prices, j)
                    if not na(p) and array.get(actives, j)
                        if d == 1 and p < L
                            tgt := na(tgt) ? p : math.max(tgt, p)
                        if d == -1 and p > L
                            tgt := na(tgt) ? p : math.min(tgt, p)

                rr    = na(tgt) or risk <= 0 ? na : math.abs(tgt - entry) / risk
                okRR  = not na(rr) and rr >= minRR
                valid = okCloses and okBars and okDepth and okPos and okColor and okTime and okRR

                side = d == 1 ? "SHORT" : "LONG"
                nm   = array.get(names, i)

                // ─── capture everything for the trace panel ───
                trcName   := nm
                trcLvl    := L
                trcSide   := side
                trcClock  := str.tostring(hour(time, tzi)) + ":" + (minute(time, tzi) < 10 ? "0" : "") + str.tostring(minute(time, tzi))
                trcExt    := ext
                trcDepthA := depthAbs
                trcDepthP := depthPct
                trcCloses := nCloses
                trcBars   := nBars
                trcO      := open
                trcH      := high
                trcL      := low
                trcC      := close
                trcPos    := posInRng
                trcEntry  := entry
                trcStop   := stop
                trcRisk   := risk
                trcT1     := t1
                trcT2     := tgt
                trcRR     := rr
                trcOkCl   := okCloses
                trcOkBr   := okBars
                trcOkDp   := okDepth
                trcOkPs   := okPos
                trcOkCo   := okColor
                trcOkTm   := okTime
                trcOkRR   := okRR
                trcValid  := valid
                trcReason := valid ? "all six checks passed" : not okCloses ? "acceptance - " + str.tostring(nCloses) + " closes beyond, max " + str.tostring(maxCloses) : not okBars ? "slow reclaim - bar " + str.tostring(nBars) + ", max " + str.tostring(maxBars) : depthPct < minDepth ? "brush - " + str.tostring(depthPct, "#.###") + "% below " + str.tostring(minDepth, "#.##") + "% min" : depthPct > maxDepth ? "too deep - " + str.tostring(depthPct, "#.###") + "% above " + str.tostring(maxDepth, "#.##") + "% max" : not okPos ? "weak close - " + str.tostring(posInRng * 100, "#.#") + "% of range" : not okColor ? "wrong colour for a " + side : not okTime ? "outside trading window" : na(rr) ? "no target available" : "R:R " + str.tostring(rr, "#.##") + " below " + str.tostring(minRR, "#.#") + " minimum"

                if valid
                    lastSig  := side + " " + nm + "  entry " + str.tostring(entry, "#.##") + "  stop " + str.tostring(stop, "#.##") + "  T1 " + str.tostring(t1, "#.##") + "  T2 " + str.tostring(tgt, "#.##") + "  " + str.tostring(rr, "#.##") + "R"
                    lastSigC := d == 1 ? color.new(color.red, 0) : color.new(color.green, 0)
                    fired    := true
                    alertMsg := "SWEEP-RECLAIM " + side + " " + nm + "\n" + "Entry " + str.tostring(entry, "#.##") + " | Stop " + str.tostring(stop, "#.##") + " | Risk " + str.tostring(risk, "#.##") + "\n" + "T1 " + str.tostring(t1, "#.##") + " (2R) | T2 " + str.tostring(tgt, "#.##") + " (" + str.tostring(rr, "#.##") + "R)\n" + "Sweep depth " + str.tostring(depthPct, "#.###") + "% | closes beyond " + str.tostring(nCloses) + " | reclaim bar " + str.tostring(nBars)
                    label.new(bar_index, d == 1 ? high : low, side + " " + nm + "\n" + str.tostring(rr, "#.##") + "R", style = d == 1 ? label.style_label_down : label.style_label_up, color = lastSigC, textcolor = color.white, size = size.normal)

                    // ─── visual risk box: draw entry/SL/T1/T2 on this valid signal ───
                    if showVR
                        line.delete(vrLineEntry)
                        line.delete(vrLineSL)
                        line.delete(vrLineT1)
                        line.delete(vrLineT2)
                        label.delete(vrLbEntry)
                        label.delete(vrLbSL)
                        label.delete(vrLbT1)
                        label.delete(vrLbT2)
                        box.delete(vrProfitBox)
                        box.delete(vrLossBox)

                        vrDir   := d == 1 ? -1 : 1   // sweep-above (d==1) reclaims into a SHORT; sweep-below (d==-1) reclaims into a LONG
                        vrEntry := entry
                        vrSL    := stop
                        vrT1    := t1
                        vrT2    := tgt
                        vrT1Hit := false
                        vrT2Hit := false
                        vrSLHit := false

                        vrEnd  = bar_index + vrLen
                        vrLblX = vrEnd + 2

                        vrLineEntry := line.new(bar_index, vrEntry, vrEnd, vrEntry, color = color.gray, width = 2)
                        vrLineSL    := line.new(bar_index, vrSL, vrEnd, vrSL, color = vrSLColor, width = 2)
                        vrLineT1    := line.new(bar_index, vrT1, vrEnd, vrT1, color = vrTPColor, width = 1, style = line.style_dashed)
                        vrLineT2    := na(vrT2) ? na : line.new(bar_index, vrT2, vrEnd, vrT2, color = vrTPColor, width = 2)

                        vrLbEntry := label.new(vrLblX, vrEntry, "ENTRY " + str.tostring(vrEntry, format.mintick), style = label.style_label_left, color = color.new(color.gray, 30), textcolor = color.white, size = size.small)
                        vrLbSL    := label.new(vrLblX, vrSL, "SL " + str.tostring(vrSL, format.mintick), style = label.style_label_left, color = color.new(vrSLColor, 40), textcolor = color.white, size = size.small)
                        vrLbT1    := label.new(vrLblX, vrT1, "T1 " + str.tostring(vrT1, format.mintick) + " (2R)", style = label.style_label_left, color = color.new(vrTPColor, 40), textcolor = color.white, size = size.small)
                        vrLbT2    := na(vrT2) ? na : label.new(vrLblX, vrT2, "T2 " + str.tostring(vrT2, format.mintick) + " (" + str.tostring(rr, "#.##") + "R)", style = label.style_label_left, color = color.new(vrTPColor, 40), textcolor = color.white, size = size.small)

                        vrProfitTop    = vrDir == 1 ? (na(vrT2) ? vrT1 : vrT2) : vrEntry
                        vrProfitBottom = vrDir == 1 ? vrEntry : (na(vrT2) ? vrT1 : vrT2)
                        vrProfitBox := box.new(left = bar_index, top = vrProfitTop, right = vrEnd, bottom = vrProfitBottom, bgcolor = vrProfitFill, border_width = 0)

                        vrLossTop    = vrDir == 1 ? vrEntry : vrSL
                        vrLossBottom = vrDir == 1 ? vrSL : vrEntry
                        vrLossBox := box.new(left = bar_index, top = vrLossTop, right = vrEnd, bottom = vrLossBottom, bgcolor = vrLossFill, border_width = 0)
                else if not studyMode
                    reason = not okCloses ? "acceptance" : not okBars ? "slow reclaim" : depthPct < minDepth ? "brush" : depthPct > maxDepth ? "too deep" : not okPos ? "weak close" : not okColor ? "wrong colour" : not okTime ? "outside window" : "R:R " + (na(rr) ? "no target" : str.tostring(rr, "#.##"))
                    lastSig  := "SKIP " + side + " " + nm + " - " + reason
                    lastSigC := color.new(color.gray, 0)

                array.set(swDir, i, 0)

if fired and alertSetups
    alert(alertMsg, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────── visual risk box: hit tracking + auto-extend

if showVR and vrDir != 0 and not na(vrLineEntry)

    if vrDir == 1
        if not na(vrT1) and high >= vrT1 and not vrT1Hit
            vrT1Hit := true
            line.set_color(vrLineT1, color.green)
            line.set_style(vrLineT1, line.style_solid)
            label.set_text(vrLbT1, "T1 ✓")
            label.set_color(vrLbT1, color.new(color.green, 40))
        if not na(vrT2) and high >= vrT2 and not vrT2Hit
            vrT2Hit := true
            line.set_color(vrLineT2, color.green)
            line.set_style(vrLineT2, line.style_solid)
            label.set_text(vrLbT2, "T2 ✓")
            label.set_color(vrLbT2, color.new(color.green, 40))
        if low <= vrSL and not vrSLHit
            vrSLHit := true
            line.set_color(vrLineSL, color.red)
            label.set_text(vrLbSL, "SL ✕")
            label.set_color(vrLbSL, color.new(color.red, 40))
    else
        if not na(vrT1) and low <= vrT1 and not vrT1Hit
            vrT1Hit := true
            line.set_color(vrLineT1, color.green)
            line.set_style(vrLineT1, line.style_solid)
            label.set_text(vrLbT1, "T1 ✓")
            label.set_color(vrLbT1, color.new(color.green, 40))
        if not na(vrT2) and low <= vrT2 and not vrT2Hit
            vrT2Hit := true
            line.set_color(vrLineT2, color.green)
            line.set_style(vrLineT2, line.style_solid)
            label.set_text(vrLbT2, "T2 ✓")
            label.set_color(vrLbT2, color.new(color.green, 40))
        if high >= vrSL and not vrSLHit
            vrSLHit := true
            line.set_color(vrLineSL, color.red)
            label.set_text(vrLbSL, "SL ✕")
            label.set_color(vrLbSL, color.new(color.red, 40))

    vrFinished = vrSLHit or vrT2Hit or (na(vrT2) and vrT1Hit)
    vrDynEnd   = vrFinished ? line.get_x2(vrLineEntry) : bar_index + vrLen

    line.set_x2(vrLineEntry, vrDynEnd)
    line.set_x2(vrLineSL, vrDynEnd)
    line.set_x2(vrLineT1, vrDynEnd)
    if not na(vrLineT2)
        line.set_x2(vrLineT2, vrDynEnd)

    vrLblX2 = vrDynEnd + 2
    label.set_x(vrLbEntry, vrLblX2)
    label.set_x(vrLbSL, vrLblX2)
    label.set_x(vrLbT1, vrLblX2)
    if not na(vrLbT2)
        label.set_x(vrLbT2, vrLblX2)

    box.set_right(vrProfitBox, vrDynEnd)
    box.set_right(vrLossBox, vrDynEnd)

// ─────────────────────────────────────────────────────────── plan alert

var bool planSent = false
if onIn and not onWas
    planSent := false

nowH = hour(time, tzi)
nowM = minute(time, tzi)

if not planSent and nowH == planHour and nowM >= planMin and barstate.isconfirmed
    planSent := true
    string pm = "SWEEP-RECLAIM PLAN " + str.tostring(nowH) + ":" + (nowM < 10 ? "0" : "") + str.tostring(nowM) + "\n"
    pm += "Price " + str.tostring(close, "#.##") + " | est. stop S " + str.tostring(S, "#.##") + "\n"
    for i = 0 to 3
        L = array.get(prices, i)
        if not na(L)
            if not array.get(actives, i)
                pm += array.get(names, i) + " " + str.tostring(L, "#.##") + "  CLUSTERED - skip\n"
            else
                dr = L > close ? -1 : 1
                float tg = na
                for j = 0 to 3
                    p = array.get(prices, j)
                    if not na(p) and array.get(actives, j) and j != i
                        if dr == -1 and p < L
                            tg := na(tg) ? p : math.max(tg, p)
                        if dr == 1 and p > L
                            tg := na(tg) ? p : math.min(tg, p)
                er = na(tg) or S <= 0 ? na : math.abs(tg - L) / S
                pm += array.get(names, i) + " " + str.tostring(L, "#.##") + "  " + (dr == -1 ? "SHORT" : "LONG") + "  tgt " + (na(tg) ? "-" : str.tostring(tg, "#.##")) + "  " + (na(er) ? "-" : str.tostring(er, "#.#") + "R") + (not na(er) and er >= minRR ? "  WATCH" : "  skip") + "\n"
    alert(pm, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────── plots

plot(showLines and not na(pdh) ? pdh : na, "PDH", color.new(color.red, 0), 1, plot.style_linebr)
plot(showLines and not na(pdl) ? pdl : na, "PDL", color.new(color.green, 0), 1, plot.style_linebr)
plot(showLines and not na(onhShow) ? onhShow : na, "ONH", color.new(color.orange, 0), 1, plot.style_linebr)
plot(showLines and not na(onlShow) ? onlShow : na, "ONL", color.new(color.blue, 0), 1, plot.style_linebr)

// ─────────────────────────────────────────────────────────── dashboard

pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : position.middle_right

var table dash = table.new(pos, 8, 9, border_width = 1)

inputsOnly = dispMode == "Inputs only"

if showTable and barstate.islast and inputsOnly
    bg  = color.new(color.gray, 90)
    hbg = color.new(color.gray, 70)
    tc  = chart.fg_color
    okRange = not na(onhLive) and not na(onlLive) and close <= onhLive and close >= onlLive
    onDiff  = not na(onh) and not na(onhLive) and (onh != onhLive or onl != onlLive)

    table.cell(dash, 0, 0, "PRE-MARKET INPUTS", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.merge_cells(dash, 0, 0, 3, 0)

    table.cell(dash, 0, 1, "PDH", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 1, na(pdh) ? "-" : str.tostring(pdh, "#.##"), bgcolor = bg, text_color = color.new(color.red, 0), text_size = txtSize)
    table.cell(dash, 2, 1, "ONH", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 1, na(onhShow) ? "-" : str.tostring(onhShow, "#.##"), bgcolor = bg, text_color = color.new(color.orange, 0), text_size = txtSize)

    table.cell(dash, 0, 2, "PDL", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 2, na(pdl) ? "-" : str.tostring(pdl, "#.##"), bgcolor = bg, text_color = color.new(color.green, 0), text_size = txtSize)
    table.cell(dash, 2, 2, "ONL", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 2, na(onlShow) ? "-" : str.tostring(onlShow, "#.##"), bgcolor = bg, text_color = color.new(color.blue, 0), text_size = txtSize)

    table.cell(dash, 0, 3, "Price", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 3, str.tostring(close, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 3, "In ON range", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 3, okRange ? "yes" : "NO - CHECK", bgcolor = bg, text_color = okRange ? color.new(color.green, 0) : color.new(color.red, 0), text_size = txtSize)

    table.cell(dash, 0, 4, "Prev ATR", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 4, na(pdATR) ? "-" : str.tostring(pdATR, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 4, "S = A x " + str.tostring(sMult, "#.#"), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 4, na(pdATR) ? "-" : str.tostring(S, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)

    table.cell(dash, 0, 5, "ATR %", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 5, na(pdATR) ? "-" : str.tostring(pdATR / close * 100, "#.###") + "%", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 5, "Cluster tol", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 5, str.tostring(clusterT, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)

    table.cell(dash, 0, 7, "ON prev", bgcolor = bg, text_color = color.new(color.gray, 40), text_size = txtSize)
    table.cell(dash, 1, 7, na(onh) ? "-" : str.tostring(onh, "#.##"), bgcolor = bg, text_color = color.new(color.gray, 40), text_size = txtSize)
    table.cell(dash, 2, 7, na(onl) ? "-" : str.tostring(onl, "#.##"), bgcolor = bg, text_color = color.new(color.gray, 40), text_size = txtSize)
    table.cell(dash, 3, 7, onDiff ? "do not use" : "same", bgcolor = bg, text_color = color.new(color.gray, 40), text_size = txtSize)

    table.cell(dash, 0, 6, "Time", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 6, str.tostring(nowH) + ":" + (nowM < 10 ? "0" : "") + str.tostring(nowM), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 6, "ON levels", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 6, inRTH ? "final" : "live", bgcolor = bg, text_color = inRTH ? tc : color.new(color.orange, 0), text_size = txtSize)

if showTable and barstate.islast and not inputsOnly
    bg  = color.new(color.gray, 90)
    hbg = color.new(color.gray, 70)
    tc  = chart.fg_color

    table.cell(dash, 0, 0, "Level", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 0, "Price", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 0, "Dir", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 0, "Target", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 4, 0, "Dist", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 5, 0, "Exp R", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 6, 0, "Swept", bgcolor = hbg, text_color = tc, text_size = txtSize)
    table.cell(dash, 7, 0, "Trade", bgcolor = hbg, text_color = tc, text_size = txtSize)

    for i = 0 to 3
        r = i + 1
        L = array.get(prices, i)
        a = array.get(actives, i)
        table.cell(dash, 0, r, array.get(names, i), bgcolor = bg, text_color = tc, text_size = txtSize)
        table.cell(dash, 1, r, na(L) ? "-" : str.tostring(L, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)

        if na(L) or not a
            for c = 2 to 6
                table.cell(dash, c, r, "-", bgcolor = bg, text_color = tc, text_size = txtSize)
            table.cell(dash, 7, r, na(L) ? "-" : "cluster", bgcolor = bg, text_color = color.new(color.gray, 0), text_size = txtSize)
        else
            dr = L > close ? -1 : 1
            float tg = na
            for j = 0 to 3
                p = array.get(prices, j)
                if not na(p) and array.get(actives, j) and j != i
                    if dr == -1 and p < L
                        tg := na(tg) ? p : math.max(tg, p)
                    if dr == 1 and p > L
                        tg := na(tg) ? p : math.min(tg, p)
            dist = na(tg) ? na : math.abs(tg - L)
            er   = na(dist) or S <= 0 ? na : dist / S
            ok   = not na(er) and er >= minRR

            table.cell(dash, 2, r, dr == -1 ? "SHORT" : "LONG", bgcolor = bg, text_color = dr == -1 ? color.new(color.red, 0) : color.new(color.green, 0), text_size = txtSize)
            table.cell(dash, 3, r, na(tg) ? "-" : str.tostring(tg, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
            table.cell(dash, 4, r, na(dist) ? "-" : str.tostring(dist, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
            table.cell(dash, 5, r, na(er) ? "-" : str.tostring(er, "#.#") + "R", bgcolor = bg, text_color = tc, text_size = txtSize)
            table.cell(dash, 6, r, array.get(swept, i) ? "yes" : "-", bgcolor = bg, text_color = array.get(swept, i) ? color.new(color.orange, 0) : tc, text_size = txtSize)
            table.cell(dash, 7, r, ok ? "WATCH" : "skip", bgcolor = bg, text_color = ok ? color.new(color.green, 0) : color.new(color.gray, 0), text_size = txtSize)

    table.cell(dash, 0, 5, "S est", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 1, 5, str.tostring(S, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 2, 5, "Price", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 3, 5, str.tostring(close, "#.##"), bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 4, 5, "Window", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 5, 5, inW ? "OPEN" : "closed", bgcolor = bg, text_color = inW ? color.new(color.green, 0) : color.new(color.gray, 0), text_size = txtSize)
    table.cell(dash, 6, 5, "ON", bgcolor = bg, text_color = tc, text_size = txtSize)
    table.cell(dash, 7, 5, inRTH ? "final" : "live", bgcolor = bg, text_color = inRTH ? tc : color.new(color.orange, 0), text_size = txtSize)

    if not studyMode
        table.cell(dash, 0, 6, "Sweeps", bgcolor = hbg, text_color = tc, text_size = txtSize)
        string act = ""
        for i = 0 to 3
            if array.get(swDir, i) != 0
                act += array.get(names, i) + " " + str.tostring(array.get(swClos, i)) + "cb/" + str.tostring(array.get(swBars, i)) + "b  "
        table.cell(dash, 1, 6, act == "" ? "none active" : act, bgcolor = bg, text_color = tc, text_size = txtSize)
        table.merge_cells(dash, 1, 6, 7, 6)

    table.cell(dash, 0, 7, showDebug ? "Debug" : "Last", bgcolor = hbg, text_color = tc, text_size = txtSize)
    dbg = "RTH " + (rthIn ? "y" : "n") + " ON " + (onIn ? "y" : "n") + " | PD " + str.tostring(pdh, "#.##") + "/" + str.tostring(pdl, "#.##") + " | ONfinal " + str.tostring(onh, "#.##") + "/" + str.tostring(onl, "#.##") + " | ONlive " + str.tostring(onhLive, "#.##") + "/" + str.tostring(onlLive, "#.##") + " | RTHacc " + str.tostring(rthHi, "#.##") + "/" + str.tostring(rthLo, "#.##") + " | pdATR " + str.tostring(nz(pdATR), "#.##")
    table.cell(dash, 1, 7, showDebug ? dbg : (lastSig == "" ? "-" : lastSig), bgcolor = bg, text_color = showDebug ? tc : lastSigC, text_size = txtSize)
    table.merge_cells(dash, 1, 7, 7, 7)

// ─────────────────────────────────────────────────────────── calculation trace panel

tPos = tracePos == "Bottom left" ? position.bottom_left : tracePos == "Bottom right" ? position.bottom_right : tracePos == "Top left" ? position.top_left : tracePos == "Middle left" ? position.middle_left : position.middle_right

var table trace = table.new(tPos, 2, 25, border_width = 1)

f2(float v) => na(v) ? "-" : str.tostring(v, "#.##")
yn(bool b)  => b ? "PASS" : "FAIL"

if showTrace and barstate.islast
    tbg  = color.new(color.gray, 88)
    thbg = color.new(color.gray, 65)
    ttc  = chart.fg_color
    pcol = color.new(color.green, 0)
    fcol = color.new(color.red, 0)

    table.cell(trace, 0, 0, "CALCULATION TRACE", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 0, "", bgcolor = thbg, text_size = trcSize)

    table.cell(trace, 0, 1, "1 - PRE-MARKET", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 1, "", bgcolor = thbg, text_size = trcSize)
    table.cell(trace, 0, 2, "PDH / PDL", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 2, f2(pdh) + "  /  " + f2(pdl), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 3, "ONH / ONL", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 3, f2(onhShow) + "  /  " + f2(onlShow), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 4, "Prev ATR x " + str.tostring(sMult, "#.#"), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 4, f2(pdATR) + "  ->  S " + f2(S), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 5, "Cluster tol", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 5, f2(clusterT) + (hiClust or loClust ? "   BAND FOUND" : "   none"), bgcolor = tbg, text_color = hiClust or loClust ? color.new(color.orange, 0) : ttc, text_size = trcSize)

    table.cell(trace, 0, 6, "2 - SWEEP", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 6, trcName == "" ? "none yet" : trcName + " " + f2(trcLvl) + "   " + trcSide + "   @ " + trcClock, bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 7, "Extreme", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 7, f2(trcExt), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 8, "Depth", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 8, f2(trcDepthA) + " pts = " + (na(trcDepthP) ? "-" : str.tostring(trcDepthP, "#.###") + "%") + "   (" + str.tostring(minDepth, "#.##") + "-" + str.tostring(maxDepth, "#.##") + "%)", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 9, "Closes beyond", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 9, str.tostring(trcCloses) + "   (max " + str.tostring(maxCloses) + ")", bgcolor = tbg, text_color = trcOkCl ? ttc : fcol, text_size = trcSize)
    table.cell(trace, 0, 10, "Reclaim on bar", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 10, str.tostring(trcBars) + "   (max " + str.tostring(maxBars) + ")", bgcolor = tbg, text_color = trcOkBr ? ttc : fcol, text_size = trcSize)

    table.cell(trace, 0, 11, "3 - RECLAIM CANDLE", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 11, "", bgcolor = thbg, text_size = trcSize)
    table.cell(trace, 0, 12, "O / H", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 12, f2(trcO) + "  /  " + f2(trcH), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 13, "L / C", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 13, f2(trcL) + "  /  " + f2(trcC), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 14, "Close in range", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 14, (na(trcPos) ? "-" : str.tostring(trcPos * 100, "#.#") + "%") + "   (need " + (trcSide == "LONG" ? ">=" + str.tostring(thirdThr * 100, "#") : "<=" + str.tostring((1 - thirdThr) * 100, "#")) + "%)", bgcolor = tbg, text_color = trcOkPs ? ttc : fcol, text_size = trcSize)
    table.cell(trace, 0, 15, "Colour", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 15, na(trcC) or na(trcO) ? "-" : (trcC > trcO ? "GREEN" : "RED") + "   (need " + (trcSide == "LONG" ? "GREEN" : "RED") + ")", bgcolor = tbg, text_color = trcOkCo ? ttc : fcol, text_size = trcSize)

    table.cell(trace, 0, 16, "4 - RULE CHECKS", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 16, "", bgcolor = thbg, text_size = trcSize)
    table.cell(trace, 0, 17, "1 closes  ·  2 timing", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 17, yn(trcOkCl) + "  ·  " + yn(trcOkBr), bgcolor = tbg, text_color = trcOkCl and trcOkBr ? pcol : fcol, text_size = trcSize)
    table.cell(trace, 0, 18, "3 depth", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 18, yn(trcOkDp), bgcolor = tbg, text_color = trcOkDp ? pcol : fcol, text_size = trcSize)
    table.cell(trace, 0, 19, "4a position  ·  4b colour", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 19, yn(trcOkPs) + "  ·  " + yn(trcOkCo), bgcolor = tbg, text_color = trcOkPs and trcOkCo ? pcol : fcol, text_size = trcSize)
    table.cell(trace, 0, 20, "5 window  ·  R:R filter", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 20, yn(trcOkTm) + "  ·  " + yn(trcOkRR), bgcolor = tbg, text_color = trcOkTm and trcOkRR ? pcol : fcol, text_size = trcSize)

    table.cell(trace, 0, 21, "5 - GEOMETRY", bgcolor = thbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 21, "", bgcolor = thbg, text_size = trcSize)
    table.cell(trace, 0, 22, "Entry / Stop / Risk", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 22, f2(trcEntry) + "  /  " + f2(trcStop) + "  /  " + f2(trcRisk), bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 0, 23, "T1 / T2 / R:R", bgcolor = tbg, text_color = ttc, text_size = trcSize)
    table.cell(trace, 1, 23, f2(trcT1) + "  /  " + f2(trcT2) + "  /  " + (na(trcRR) ? "-" : str.tostring(trcRR, "#.##") + "R  need " + str.tostring(minRR, "#.#")), bgcolor = tbg, text_color = trcOkRR ? ttc : fcol, text_size = trcSize)

    // vrDir persists from the last VALID signal. When the newest verdict is a skip,
    // no trade opened from it - say so, and mark any surviving status as belonging
    // to an earlier signal rather than this one.
    priorSt = vrDir == 0 ? "none" : vrSLHit ? "STOPPED OUT" : vrT2Hit ? "T2 HIT - closed" : vrT1Hit ? "T1 HIT - runner open" : "OPEN"
    trdSt   = trcName == "" ? "no trade" : trcValid ? priorSt : (vrDir == 0 ? "no trade - last verdict was a skip" : "no trade from this skip  ·  earlier: " + priorSt)
    trdCo   = not trcValid ? ttc : vrDir == 0 ? ttc : vrSLHit ? fcol : (vrT2Hit or vrT1Hit) ? pcol : color.new(color.orange, 0)

    table.cell(trace, 0, 24, trcName == "" ? "VERDICT: -" : (trcValid ? "TAKE - " : "SKIP - ") + trcReason, bgcolor = thbg, text_color = trcName == "" ? ttc : trcValid ? pcol : fcol, text_size = trcSize)
    table.cell(trace, 1, 24, "TRADE: " + trdSt, bgcolor = thbg, text_color = trdCo, text_size = trcSize)

// Must be last: these hold the PREVIOUS bar's session state for everything above.
rthWas := rthIn
onWas  := onIn
````

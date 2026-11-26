# Multi-TF Profiles & VWAPs [edge]

- url: https://www.tradingview.com/script/HdpX22wO-Multi-TF-Profiles-VWAPs-edge/
- type: indicator
- pine_id: PUB;0e0ab9b1b4044117b937b9ad96f996fc
- version: 2.0

## Description

A multi-pattern intraday execution indicator built for precision trading around high-probability zones.

This tool combines higher timeframe context with 2-minute execution logic to identify breakout, continuation, reversal, mean reversion, and failed breakout setups—all structured through a clean ABC grading system.

Instead of relying on a single trigger like engulfing candles, the indicator evaluates a stack of confirmations, including:

liquidity sweeps
reclaim and rejection behavior
acceptance above/below value
displacement (CSD)
imbalance (IFVG)
structural context relative to key zones

The result is a structured framework that distinguishes between:

early setup formation (awareness)
confirmed execution signals (precision)

Each signal is graded based on:

location quality
confirmation strength
structural alignment
risk/reward clarity

Designed for intraday traders, the core execution logic is optimized on the 2-minute timeframe, while still respecting higher timeframe context.

This indicator does not aim to predict the market.
It aims to filter noise and highlight asymmetric opportunities.

## Source Code

````pine
//@version=6
// v3.12 - Adds two-stage early/forming signal system: small circle fires one bar earlier than the confirmed engulf trigger when price enters a zone with directional pressure. Full ABC grading, optional labels, webhook JSON, and per-grade alertconditions. Confirmed ABC signals and all existing visuals unchanged.
indicator("Multi-TF Profiles & VWAPs [edge]", "MTF-PV", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ─────────────────────────────────────────────────────────────────
gProf = "Volume Profiles"

showMo      = input.bool(true,  "Monthly",   group=gProf, inline="m")
showMoHist  = input.bool(false, "Hist",      group=gProf, inline="m")
showPrevMo  = input.bool(true,  "Prev",      group=gProf, inline="m", tooltip="Show prior monthly profiles (pM). Turn off to only see the current month.")
nMo         = input.int (1,     "Back",      minval=0, maxval=5, group=gProf, inline="m", tooltip="Prior completed monthly profiles to display (0 = current only).")
colMo       = input.color(color.new(color.red,     0), "", group=gProf, inline="m")

showWk      = input.bool(true,  "Weekly",    group=gProf, inline="w")
showWkHist  = input.bool(false, "Hist",      group=gProf, inline="w")
showPrevWk  = input.bool(true,  "Prev",      group=gProf, inline="w", tooltip="Show prior weekly profiles (pW). Turn off to only see the current week.")
nWk         = input.int (2,     "Back",      minval=0, maxval=5, group=gProf, inline="w")
colWk       = input.color(color.new(color.purple,  0), "", group=gProf, inline="w")

showD       = input.bool(true,  "Daily",     group=gProf, inline="d")
showDHist   = input.bool(false, "Hist",      group=gProf, inline="d")
showPrevD   = input.bool(true,  "Prev",      group=gProf, inline="d", tooltip="Show prior daily profiles (pD). Turn off to only see today's profile.")
nD          = input.int (3,     "Back",      minval=0, maxval=5, group=gProf, inline="d")
colD        = input.color(color.new(color.blue,    0), "", group=gProf, inline="d")

show4h      = input.bool(true,  "4-Hour",    group=gProf, inline="4")
show4hHist  = input.bool(false, "Hist",      group=gProf, inline="4")
n4h         = input.int (3,     "Back",      minval=0, maxval=5, group=gProf, inline="4")
col4h       = input.color(color.new(color.teal,    0), "", group=gProf, inline="4")

binTicks   = input.int(8,  "Bin size (ticks)", minval=1, maxval=500, group=gProf, tooltip="Each bin = mintick × this value. NQ: 4=1pt, 8=2pt, 20=5pt, 100=25pt. Smaller = more detail but more boxes. Monthly/Weekly histograms may need 20+ to stay under Pine's 500-box limit when multiple profiles are back-stacked.")
histWidth  = input.int(40, "Histogram max width (bars)", minval=10, maxval=200, group=gProf, tooltip="Capped to each profile's actual bar count so histograms stay inside their period.")
histOffset = input.int(0,  "Histogram offset (bars right of period start)", minval=0, maxval=50, group=gProf)
vaPct      = input.float(0.70, "Value Area %", minval=0.5, maxval=0.9, step=0.01, group=gProf)
extendR         = input.bool(true,  "Extend CURRENT profile lines to right", group=gProf, tooltip="Only the most-recent profile per TF extends to the right of the chart. Historical profiles draw only across their own period.")
showLbl         = input.bool(true,  "Show labels on current profiles", group=gProf)
showPrevLabels  = input.bool(true,  "Label prior levels (pD / pW / pM)", group=gProf, tooltip="Draw labels at the right edge for the POC/VAH/VAL of prior profiles. Tag is pD (yesterday), p2D (two days ago), pW (last week), etc. Labels sharing the same price are merged into one (e.g. 'pW POC + pD VAH').")
combineExactLabels = input.bool(true, "Combine labels at exact same price", group=gProf, tooltip="When on, labels at tick-identical prices are merged into one: 'pW POC + pD VAH'. When off, each level draws its own label.")

gVwap   = "VWAPs"
showDv  = input.bool(true,  "Daily VWAP",   group=gVwap, inline="dv")
colDv   = input.color(color.new(color.yellow, 0), "",  group=gVwap, inline="dv")
showWv  = input.bool(true,  "Weekly VWAP",  group=gVwap, inline="wv")
colWv   = input.color(color.new(color.fuchsia, 0), "", group=gVwap, inline="wv")
showNy  = input.bool(true,  "NY Session VWAP", group=gVwap, inline="ny")
colNy   = input.color(color.new(color.lime, 0), "",   group=gVwap, inline="ny")
showBnd = input.bool(true,  "± 1σ / 2σ bands", group=gVwap)
nySess  = input.session("0930-1615", "NY session (exchange tz)", group=gVwap)

gBias    = "Strategy Bias"
showBias = input.bool(true, "Show bias table (D + W)", group=gBias, tooltip="Classifies current Daily shape + price vs prior-day VA. Adds Weekly trend as a higher-timeframe context nudge (±1 each signal).")
atrLen       = input.int  (14,  "ATR length",             minval=5,  maxval=50, group=gBias, inline="m1", tooltip="Used by the ATR row for stop-width calibration. Typical stop ≈ 1.5 × ATR or structural, whichever is wider.")
volLookback  = input.int  (10,  "Volume lookback",        minval=5,  maxval=30, group=gBias, inline="m1")
cvdLen       = input.int  (5,   "CVD lookback (bars)",    minval=2,  maxval=30, group=gBias, inline="m1", tooltip="How many bars back to compare cumulative volume delta against. Lower = more responsive. Default 5 = 10 min on 2m chart.")
showClusters = input.bool (true, "Highlight level clusters", group=gBias, inline="cl")
clusterWidth = input.float(8.0, "Cluster width (pts)",    minval=1.0, maxval=50.0, step=0.5, group=gBias, inline="cl", tooltip="Levels within this point distance group into one cluster. Clusters with ≥2 levels get a highlighted zone.")
showTrigger     = input.bool (true, "Mark reversal triggers at levels", group=gBias, inline="trg", tooltip="Fires a single GO signal: prior bar touched a level (pin / doji / rejection) AND current bar commits the reversal by closing past the prior bar's high (bull) or low (bear) with a real body. Green ▲ below = go long. Red ▼ above = go short.")
trigBodyPct     = input.float(0.5, "Trigger body/range",  minval=0.2, maxval=0.9,  step=0.05, group=gBias, inline="trg2", tooltip="Trigger bar's body must be at least this fraction of its range. Filters weak wicky commit bars. 0.5 = body ≥ half the range.")
engulfLevelDist = input.float(3.0, "Level tol (pts)",     minval=0.1, maxval=50.0, step=0.1, group=gBias, inline="trg2", tooltip="Maximum distance between the prior bar's wick and a level for it to count as 'at level'. Per symbol: GC 2, NQ 10, ES 3, CL 0.3.")

gTicket         = "Trade Ticket & Grade"
showTicket      = input.bool (true,   "Show trade ticket on each trigger",   group=gTicket, tooltip="Draws a label next to every trigger showing: A/B/C grade, direction, entry, stop + pts, TP1 + pts, TP2 + pts, and position size in contracts for your account+risk.")
showGrade       = input.bool (true,   "Show A/B/C grade letter",             group=gTicket, tooltip="Colors the triangle + prepends an A/B/C grade to the ticket. A = take full-size. B = half-size. C = skip or use for practice only.")
accountSize     = input.float(100000, "Account size ($)",  minval=1000, maxval=100000000, step=1000, group=gTicket, inline="risk")
riskPct         = input.float(0.5,    "Risk per trade (%)", minval=0.05, maxval=5.0,  step=0.05, group=gTicket, inline="risk", tooltip="% of account risked per trade. Position size = risk$ / (stop distance × $/pt). Uses syminfo.pointvalue for futures contract multiplier.")
atrStopMult     = input.float(1.5,    "ATR stop multiplier", minval=0.5, maxval=5.0,  step=0.1, group=gTicket, tooltip="Stop = max(structural, atrMult × ATR). Ensures stop is at least this wide regardless of rejection bar size.")
tpMode          = input.string("Next levels", "Targets",     options=["Next levels", "R multiples"], group=gTicket, tooltip="'Next levels' = use the nearest 2 profile levels in trigger direction. 'R multiples' = 1R (TP1) and 2R (TP2) based on stop distance.")

gIB             = "Initial Balance"
showIB          = input.bool(true,  "Show IB high/low lines",     group=gIB, tooltip="Draws the first-hour RTH range (09:30-10:30 ET) as persistent horizontal lines. IB high and IB low act as magnets + rejection levels for the rest of the session.")
ibSess          = input.session("0930-1030", "IB session (ET)",    group=gIB, tooltip="Default 09:30-10:30 ET — the CME/NYSE cash open first hour.")
ibColor         = input.color(color.new(color.orange, 0), "IB line color", group=gIB, inline="ib2")
ibUseAsLevel    = input.bool(true,  "Use IB as trigger level",    group=gIB, inline="ib2", tooltip="Count IB high/low as levels for the reversal trigger detector (rejection there fires arrows).")

// ─── EARLY SIGNAL INPUTS ────────────────────────────────────────────────────
// Controls the two-stage forming/warning system. Confirmed ABC is unaffected.
gEarly           = "Early Signals"
earlyEnabled     = input.bool  (false,       "Enable early signals",                          group=gEarly, tooltip="Fires a small circle marker on the zone-interaction bar — one full bar before the confirmed engulf signal. The confirmed ABC signal and all its visuals are unchanged.")
earlyMinGrade    = input.string("C",         "Min early grade",  options=["A","B","C"],        group=gEarly, inline="eg1", tooltip="Only show early signals at or above this grade. A (score ≥5) is strictest. C = all contextual awareness signals.")
earlySensitivity = input.string("normal",    "Sensitivity",      options=["conservative","normal","aggressive"], group=gEarly, inline="eg1", tooltip="Conservative: kill zone + aligned bias required. Normal: aligned daily bias only. Aggressive: any zone touch + body direction — most signals, most noise.")
earlyReqHTFZone  = input.bool  (true,        "HTF zone only (D/W/M profiles)",                group=gEarly, inline="ef1", tooltip="Restrict early signals to Daily, Weekly, or Monthly POC/VAH/VAL. Off = also fires at VWAPs and IB levels.")
earlyReqSweep    = input.bool  (false,       "Require liquidity sweep",                       group=gEarly, inline="ef1", tooltip="Prior bar must have pierced BELOW support (long) or ABOVE resistance (short) before the current bar forms an early signal — stop-hunt confirmed.")
earlyReqReclaim  = input.bool  (false,       "Require reclaim (close > bar midpoint)",        group=gEarly, inline="ef2", tooltip="Current bar must close above its own midpoint (bull) or below (bear) — the bar is already leaning in trade direction.")
earlyReqDisplace = input.bool  (false,       "Require partial displacement (body ≥0.25 ATR)", group=gEarly, inline="ef2", tooltip="Current bar body must be at least 25% of ATR in the reaction direction.")
showEarlyLabels  = input.bool  (true,        "Show forming labels",                           group=gEarly, inline="ev1")
earlyAlertEn     = input.bool  (true,        "Early alert (webhook)",                         group=gEarly, inline="ev1", tooltip="Fires alert() with forming-signal JSON when an early signal is detected. Use 'Any alert() call' condition in TradingView.")

// ─── SETUP ENGINE ────────────────────────────────────────────────────────────
gEngine              = "Setup Engine"
enableBreakoutSetups = input.bool(true,  "Breakout setups",           group=gEngine, inline="s1")
enableContSetups     = input.bool(true,  "Continuation setups",       group=gEngine, inline="s1")
enableRevSetups      = input.bool(true,  "Reversal setups",           group=gEngine, inline="s2")
enableMRSetups       = input.bool(true,  "Mean reversion setups",     group=gEngine, inline="s2")
enableFBSetups       = input.bool(true,  "Failed breakout setups",    group=gEngine, inline="s3")
minPatternScore      = input.int (3,     "Min pattern score (1–10)",  minval=1, maxval=10, group=gEngine, tooltip="Minimum score a detector must reach to fire. 3=normal, 5=strict, 7=very strict.")
showSetupLabel       = input.bool(true,  "Show setup type in ticket", group=gEngine, tooltip="Prepends [continuation] / [breakout] etc. to the trade ticket label.")
webhookIncludeStack  = input.bool(true,  "Webhook: send confirmation stack", group=gEngine)

// ─── SIGNAL GATES ────────────────────────────────────────────────────────────
gGate              = "Signal Gates"
minSetupScore      = input.int (65,   "Min setup score (0–100)",      minval=0, maxval=100, group=gGate, tooltip="Engine score × 10 = composite quality (0–100). A-grade ≥ 80, B-grade ≥ 65, C-grade ≥ 50. Default 65 = B minimum.")
minConfirmations   = input.int (2,    "Min confirmations required",    minval=1, maxval=7,   group=gGate, tooltip="Number of independent confirmation signals needed: sweep, CSD, IFVG, acceptance, rejection, strong-reclaim, failed-acceptance. A-grade signals auto-require 3+.")
signalCooldownBars = input.int (10,   "Signal cooldown (bars)",        minval=0, maxval=100, group=gGate, tooltip="Minimum bars between signals in the same direction. Prevents zone-spam when price lingers near a level.")
requireValidLoc    = input.bool(true, "Require valid location",                               group=gGate, tooltip="Block signals when price is not near a recognised level: VAH, VAL, POC, VWAP, IB, or extreme VWAP deviation.")
reqMedZoneQuality  = input.bool(true, "Require medium+ zone quality",                         group=gGate, tooltip="Level must score priority ≥ 1. Blocks signals at generic low-quality levels.")
suppressMidBalance = input.bool(true, "Suppress middle-of-balance",                           group=gGate, tooltip="Block signals when price is mid value-area (not near VAH/VAL/POC). Mean-reversion setups bypass this.")
showDebugTable     = input.bool(false,"Signal debug table",                                    group=gGate, tooltip="Show on-bar debug overlay: validLoc, confirmCount, setupScore, cooldown, block reason.")

// ─── SCALP FILTER ────────────────────────────────────────────────────────────
gScalp             = "Scalp Filter"
maxStopPoints      = input.float(10.0, "Max stop distance (pts)",    minval=0.5, maxval=200.0, step=0.5, group=gScalp, tooltip="Hard block if structural stop is farther than this from close. Tune per instrument (ES: 10, NQ: 40, CL: 0.5).")
prefStopPoints     = input.float(5.0,  "Preferred stop (pts)",       minval=0.5, maxval=100.0, step=0.5, group=gScalp, tooltip="Stop at or below this = full entry-quality score. Above this but ≤ max = partial score.")
maxEntryExtPts     = input.float(10.0, "Max entry extension (pts)",  minval=0.0, maxval=100.0, step=0.5, group=gScalp, tooltip="Block if close has extended more than this beyond the trigger level. Prevents chasing.")
minRR              = input.float(1.5,  "Min risk/reward",            minval=0.5, maxval=10.0,  step=0.1, group=gScalp, tooltip="Minimum reward-to-risk vs nearest structural level. Turn off RR filter to bypass.")
enableRRFilter     = input.bool (true, "Enable RR filter",                                                group=gScalp, tooltip="When off, RR check is skipped and all valid setups pass regardless of nearby level distance.")

// ─── PROFILE TYPE ───────────────────────────────────────────────────────────
type Profile
    map<float, float> bins
    float periodHi
    float periodLo
    int   periodStartBar
    int   periodEndBar      // -1 while this profile is the current (still accumulating)
    line  lPoc
    line  lVah
    line  lVal
    label bPoc
    label bVah
    label bVal
    array<box> histBoxes
    float poc
    float vah
    float val

makeProfile() =>
    Profile.new(map.new<float, float>(), na, na, -1, -1, na, na, na, na, na, na, array.new<box>(), na, na, na)

// Add a bar's volume, distributed LINEARLY across its high-low range at binTicks
// resolution. A 1h bar spanning 50 points contributes to every bin in that range.
method addBar(Profile p, float h, float l, float c, float v) =>
    if p.periodStartBar < 0
        p.periodStartBar := bar_index
    if not na(h) and not na(l) and not na(c) and not na(v) and v > 0 and h >= l
        float binSize = syminfo.mintick * binTicks
        float loBin   = math.round(l / binSize) * binSize
        float hiBin   = math.round(h / binSize) * binSize
        int   nBins   = int(math.round((hiBin - loBin) / binSize)) + 1
        if nBins <= 1
            float tp     = (h + l + c) / 3.0
            float binKey = math.round(tp / binSize) * binSize
            float prev   = map.contains(p.bins, binKey) ? map.get(p.bins, binKey) : 0.0
            map.put(p.bins, binKey, prev + v)
        else
            float perBin = v / nBins
            for i = 0 to nBins - 1
                float binKey = loBin + i * binSize
                float prev   = map.contains(p.bins, binKey) ? map.get(p.bins, binKey) : 0.0
                map.put(p.bins, binKey, prev + perBin)
        p.periodHi := na(p.periodHi) ? h : math.max(p.periodHi, h)
        p.periodLo := na(p.periodLo) ? l : math.min(p.periodLo, l)

// Compute POC, VAH, VAL from accumulated bins
method compute(Profile p) =>
    int n = map.size(p.bins)
    if n > 0
        array<float> keys = map.keys(p.bins)
        array.sort(keys, order.ascending)
        float totalVol = 0.0
        float pocVol   = 0.0
        int   pocIdx   = 0
        for i = 0 to n - 1
            float v = map.get(p.bins, array.get(keys, i))
            totalVol += v
            if v > pocVol
                pocVol := v
                pocIdx := i
        p.poc := array.get(keys, pocIdx)
        float target = totalVol * vaPct
        float acc    = pocVol
        int loI = pocIdx
        int hiI = pocIdx
        while acc < target and (loI > 0 or hiI < n - 1)
            float upVol = hiI < n - 1 ? map.get(p.bins, array.get(keys, hiI + 1)) : -1.0
            float dnVol = loI > 0     ? map.get(p.bins, array.get(keys, loI - 1)) : -1.0
            if upVol < 0 and dnVol < 0
                break
            if upVol >= dnVol
                hiI += 1
                acc += map.get(p.bins, array.get(keys, hiI))
            else
                loI -= 1
                acc += map.get(p.bins, array.get(keys, loI))
        p.vah := array.get(keys, hiI)
        p.val := array.get(keys, loI)
    else
        p.poc := na
        p.vah := na
        p.val := na

// Delete all graphics owned by this profile (lines, labels, hist boxes)
method cleanup(Profile p) =>
    line.delete(p.lPoc)
    line.delete(p.lVah)
    line.delete(p.lVal)
    label.delete(p.bPoc)
    label.delete(p.bVah)
    label.delete(p.bVal)
    while array.size(p.histBoxes) > 0
        box.delete(array.pop(p.histBoxes))

// Render POC/VAH/VAL + optional histogram for ONE profile, positioned at its own
// period range. extendRight=true extends lines past the right edge (current only).
// withLabel=true adds POC/VAH/VAL text labels (current only by default).
method render(Profile p, color col, string lbl, bool extendRight, bool withLabel, bool showHist, int histOff) =>
    p.cleanup()
    if not na(p.poc)
        int xStart = p.periodStartBar >= 0 ? p.periodStartBar : bar_index - 50
        int xEnd   = p.periodEndBar   >= 0 ? p.periodEndBar   : (extendRight ? bar_index + 20 : bar_index)
        // Guard against degenerate ranges (can happen on very first bar edge cases)
        if xEnd <= xStart
            xEnd := xStart + 1
        // Clamp x-coords to within Pine's ~9000-bar line.new/box.new limit.
        // On a 2m chart with many bars loaded, the prior-Monthly's periodStartBar
        // can easily sit >9000 bars back, which throws "RE10026: Bar index value
        // of the x1 argument is too far from the current bar index" and breaks
        // the entire indicator until the chart is refreshed. Clamping preserves
        // the correct POC/VAH/VAL prices while truncating the visible line span
        // to the allowed window. If the whole profile is already past that
        // window (fully off-screen anyway), we skip drawing it entirely.
        int maxBack = 4900
        bool skipTooOld = xEnd < bar_index - maxBack
        if not skipTooOld
            if xStart < bar_index - maxBack
                xStart := bar_index - maxBack
            p.lPoc := line.new(xStart, p.poc, xEnd, p.poc, color=col, width=2, style=line.style_solid)
            p.lVah := line.new(xStart, p.vah, xEnd, p.vah, color=col, width=1, style=line.style_dashed)
            p.lVal := line.new(xStart, p.val, xEnd, p.val, color=col, width=1, style=line.style_dashed)
            if withLabel
                p.bPoc := label.new(xEnd, p.poc, lbl + " POC " + str.tostring(p.poc, format.mintick), color=color.new(col, 85), style=label.style_label_left, textcolor=col, size=size.small)
                p.bVah := label.new(xEnd, p.vah, lbl + " VAH " + str.tostring(p.vah, format.mintick), color=color.new(col, 85), style=label.style_label_left, textcolor=col, size=size.tiny)
                p.bVal := label.new(xEnd, p.val, lbl + " VAL " + str.tostring(p.val, format.mintick), color=color.new(col, 85), style=label.style_label_left, textcolor=col, size=size.tiny)
            if showHist
                float binSize = syminfo.mintick * binTicks
                array<float> keys = map.keys(p.bins)
                int nBins = array.size(keys)
                // Cap histogram width to the profile's actual duration so historical
                // histograms stay contained inside their own period.
                int periodBars   = math.max(1, xEnd - xStart)
                int effHistWidth = math.max(1, math.min(histWidth, periodBars - histOff))
                if nBins > 0 and nBins <= 450
                    float maxV = 0.0
                    for k in keys
                        float v = map.get(p.bins, k)
                        if v > maxV
                            maxV := v
                    if maxV > 0
                        int histLeft = xStart + histOff
                        for k in keys
                            float v = map.get(p.bins, k)
                            int barW = math.max(1, math.round((v / maxV) * effHistWidth))
                            bool inVA = k >= p.val and k <= p.vah
                            color bgc = inVA ? color.new(col, 55) : color.new(col, 82)
                            box b = box.new(histLeft, k + binSize / 2, histLeft + barW, k - binSize / 2, bgcolor=bgc, border_color=na)
                            array.push(p.histBoxes, b)

// ─── PROFILE LISTS (one per TF, newest at the tail) ────────────────────────
var array<Profile> pMoList = array.new<Profile>()
var array<Profile> pWkList = array.new<Profile>()
var array<Profile> pDList  = array.new<Profile>()
var array<Profile> p4hList = array.new<Profile>()

// Ensure each list has a current profile to accumulate into
if array.size(pMoList) == 0
    array.push(pMoList, makeProfile())
if array.size(pWkList) == 0
    array.push(pWkList, makeProfile())
if array.size(pDList) == 0
    array.push(pDList, makeProfile())
if array.size(p4hList) == 0
    array.push(p4hList, makeProfile())

// ─── PERIOD CHANGE DETECTION ────────────────────────────────────────────────
bool newMo  = timeframe.change("M")
bool newWk  = timeframe.change("W")
bool newD   = timeframe.change("D")
bool new4h  = timeframe.change("240")

// Roll the list: finalize the current profile (compute + endBar), push a new
// empty one. Trim excess from the head (deleting their graphics).
rollList(array<Profile> lst, int nBack) =>
    int sz = array.size(lst)
    if sz > 0
        Profile cur = array.get(lst, sz - 1)
        cur.compute()
        cur.periodEndBar := bar_index - 1
    array.push(lst, makeProfile())
    // Keep nBack historical + 1 current
    while array.size(lst) > nBack + 1
        Profile old = array.shift(lst)
        old.cleanup()

if newMo
    rollList(pMoList, nMo)
if newWk
    rollList(pWkList, nWk)
if newD
    rollList(pDList, nD)
if new4h
    rollList(p4hList, n4h)

// Accumulate volume on each bar into the CURRENT profile (last element).
// Mo/Wk/D always feed so the bias analyzer has data even when their graphics
// are toggled off. 4h only feeds when displayed.
feedLast(array<Profile> lst, bool on) =>
    if on
        int sz = array.size(lst)
        if sz > 0
            Profile cur = array.get(lst, sz - 1)
            cur.addBar(high, low, close, volume)

feedLast(pMoList, true)
feedLast(pWkList, true)
feedLast(pDList,  true)
feedLast(p4hList, show4h)

// Render every profile in the list on the last bar. Current = last element:
// extends right + labeled. Historical = contained in own period, no labels.
// showPrev=false hides all non-current profiles in the list.
renderList(array<Profile> lst, color col, string lbl, bool show, bool showHist, bool extendR2, bool showLbl2, int histOff, int nBack, bool showPrev) =>
    // Trim any excess if user lowered nBack at runtime
    while array.size(lst) > nBack + 1
        Profile old = array.shift(lst)
        old.cleanup()
    if show
        int sz = array.size(lst)
        for i = 0 to sz - 1
            Profile p = array.get(lst, i)
            bool isCurrent = (i == sz - 1)
            if isCurrent
                p.compute()
                p.render(col, lbl, extendR2, showLbl2, showHist, histOff)
            else if showPrev
                p.render(col, lbl, false, false, showHist, histOff)
            else
                p.cleanup()
    else
        // Profile hidden: wipe any stale graphics
        for i = 0 to array.size(lst) - 1
            Profile p = array.get(lst, i)
            p.cleanup()

// Render throttle — full drawing pass runs only on the first tick of a new
// bar, not every incoming tick. On a 2m chart the per-tick work (recreate
// every line/label/histogram box for every profile across every TF) exceeds
// Pine's compute budget after the first bar-close transition and the script
// visually freezes until you refresh. Gating on bar_index change eliminates
// the problem. Lines/labels don't need to update intra-bar — only on bar
// close does a profile's POC/VA meaningfully shift. The bias table keeps
// updating every tick below because it's text-only (no drawing cost).
var int lastRenderBar = -1
bool shouldDraw = barstate.islast and bar_index != lastRenderBar

if shouldDraw
    renderList(pMoList, colMo, "Mo", showMo, showMoHist, extendR, showLbl, histOffset, nMo, showPrevMo)
    renderList(pWkList, colWk, "W",  showWk, showWkHist, extendR, showLbl, histOffset, nWk, showPrevWk)
    renderList(pDList,  colD,  "D",  showD,  showDHist,  extendR, showLbl, histOffset, nD,  showPrevD)
    renderList(p4hList, col4h, "4H", show4h, show4hHist, extendR, showLbl, histOffset, n4h, true)

// ─── PRIOR-LEVEL LABELS (pD / pW / pM, merged at same price) ────────────────
// Collects POC/VAH/VAL of every *prior* profile across the shown Mo/Wk/D lists
// into a single price-keyed map so levels that share a price combine into one
// label (e.g. "pW POC + pD VAH  26500.00") instead of stacking on top of each
// other at the right edge.
var array<label> prevLvlLabels = array.new<label>()

drawUncombined(int xEnd, array<Profile> lst, string tfChar, color c, bool enabled) =>
    if enabled
        int sz = array.size(lst)
        if sz >= 2
            for i = 0 to sz - 2
                Profile p = array.get(lst, i)
                int age       = sz - 1 - i
                string ageTag = age == 1 ? "p" + tfChar : "p" + str.tostring(age) + tfChar
                if not na(p.poc)
                    label lbl1 = label.new(xEnd, p.poc, ageTag + " POC  " + str.tostring(p.poc, format.mintick), color=color.new(color.black, 80), style=label.style_label_left, textcolor=c, size=size.tiny)
                    array.push(prevLvlLabels, lbl1)
                if not na(p.vah)
                    label lbl2 = label.new(xEnd, p.vah, ageTag + " VAH  " + str.tostring(p.vah, format.mintick), color=color.new(color.black, 80), style=label.style_label_left, textcolor=c, size=size.tiny)
                    array.push(prevLvlLabels, lbl2)
                if not na(p.val)
                    label lbl3 = label.new(xEnd, p.val, ageTag + " VAL  " + str.tostring(p.val, format.mintick), color=color.new(color.black, 80), style=label.style_label_left, textcolor=c, size=size.tiny)
                    array.push(prevLvlLabels, lbl3)

// Integer tick-count key: avoids float-equality failures in map lookups.
// k = int(math.round(price / syminfo.mintick)) — exact integer, no rounding error.
addPrevLvl(map<int, string> txtM, map<int, color> colM, float price, string tag, color c) =>
    if not na(price)
        int key = int(math.round(price / syminfo.mintick))
        string existing = map.contains(txtM, key) ? map.get(txtM, key) : ""
        string combined = existing == "" ? tag : existing + " + " + tag
        map.put(txtM, key, combined)
        if not map.contains(colM, key)
            map.put(colM, key, c)

addPrevProfiles(map<int, string> txtM, map<int, color> colM, array<Profile> lst, string tfChar, color c, bool enabled) =>
    if enabled
        int sz = array.size(lst)
        if sz >= 2
            for i = 0 to sz - 2
                Profile p = array.get(lst, i)
                if not na(p.poc)
                    int age = sz - 1 - i
                    string ageTag = age == 1 ? "p" + tfChar : "p" + str.tostring(age) + tfChar
                    addPrevLvl(txtM, colM, p.poc, ageTag + " POC", c)
                    addPrevLvl(txtM, colM, p.vah, ageTag + " VAH", c)
                    addPrevLvl(txtM, colM, p.val, ageTag + " VAL", c)

if shouldDraw
    while array.size(prevLvlLabels) > 0
        label.delete(array.pop(prevLvlLabels))
    if showPrevLabels
        int xEnd = bar_index + 25
        if combineExactLabels
            map<int, string> txtM = map.new<int, string>()
            map<int, color>  colM = map.new<int, color>()
            addPrevProfiles(txtM, colM, pMoList, "M", colMo, showMo)
            addPrevProfiles(txtM, colM, pWkList, "W", colWk, showWk)
            addPrevProfiles(txtM, colM, pDList,  "D", colD,  showD)
            array<int> keys = map.keys(txtM)
            for k in keys
                string txt  = map.get(txtM, k)
                color  c    = map.get(colM, k)
                float  price = float(k) * syminfo.mintick
                label lbl = label.new(xEnd, price, txt + "  " + str.tostring(price, format.mintick), color=color.new(color.black, 80), style=label.style_label_left, textcolor=c, size=size.tiny)
                array.push(prevLvlLabels, lbl)
        else
            drawUncombined(xEnd, pMoList, "M", colMo, showMo)
            drawUncombined(xEnd, pWkList, "W", colWk, showWk)
            drawUncombined(xEnd, pDList,  "D", colD,  showD)
    lastRenderBar := bar_index

// ─── LEVEL CLUSTER HIGHLIGHTER ──────────────────────────────────────────────
// Collects current + prior POC/VAH/VAL across Mo/Wk/D lists, sorts them, then
// groups sequentially when the gap to the next level is ≤ clusterWidth.
// Clusters with ≥2 levels get a translucent rectangle spanning ~200 bars back
// to 20 bars right of the current bar. Stronger clusters (≥3 levels) draw
// yellow; 2-level clusters draw aqua.
var array<box> clusterBoxes = array.new<box>()

collectLvl(array<float> lvls, Profile p) =>
    if not na(p.poc)
        array.push(lvls, p.poc)
    if not na(p.vah)
        array.push(lvls, p.vah)
    if not na(p.val)
        array.push(lvls, p.val)

collectFromList(array<float> lvls, array<Profile> lst, bool incPriors) =>
    int sz = array.size(lst)
    if sz > 0
        collectLvl(lvls, array.get(lst, sz - 1))
        if incPriors
            for i = 0 to sz - 2
                collectLvl(lvls, array.get(lst, i))

if shouldDraw
    while array.size(clusterBoxes) > 0
        box.delete(array.pop(clusterBoxes))
    if showClusters
        array<float> lvls = array.new<float>()
        collectFromList(lvls, pDList,  showPrevD  and showD)
        collectFromList(lvls, pWkList, showPrevWk and showWk)
        collectFromList(lvls, pMoList, showPrevMo and showMo)
        array.sort(lvls, order.ascending)
        int xR = bar_index + 20
        int xL = math.max(bar_index - 200, bar_index - 4900)
        int nL = array.size(lvls)
        int i = 0
        while i < nL
            float clusterLo = array.get(lvls, i)
            float clusterHi = clusterLo
            int count = 1
            int j = i + 1
            while j < nL and array.get(lvls, j) - clusterHi <= clusterWidth
                clusterHi := array.get(lvls, j)
                count += 1
                j += 1
            if count >= 2
                color bgCol = count >= 3 ? color.new(color.yellow, 88) : color.new(color.aqua, 90)
                box b = box.new(xL, clusterHi, xR, clusterLo, border_color=color.new(color.gray, 70), border_width=1, bgcolor=bgCol)
                array.push(clusterBoxes, b)
            i := j

// ─── STRATEGY METRICS (ATR / Volume regime / CVD) ──────────────────────────
// Runs every bar so the bias table rows stay current even when the render
// throttle skips a redraw.
float atrVal   = ta.atr(atrLen)
float avgVol   = ta.sma(volume, volLookback)
float volRatio = avgVol > 0 ? volume / avgVol : 0.0
string volLbl  = volRatio >= 2.0 ? "SPIKE"    : volRatio >= 1.3 ? "Interest" : volRatio >= 0.6 ? "Normal" : "Quiet"
color  volCol  = volRatio >= 2.0 ? color.fuchsia : volRatio >= 1.3 ? color.orange  : volRatio >= 0.6 ? color.new(color.gray, 40) : color.new(color.gray, 70)

// Cumulative Volume Delta — range-weighted. Instead of crude
//   close >= open ? +v : -v     (one bit per bar, lags ~10 bars)
// we use how far close sat inside the bar's range:
//   delta = ((close - low) - (high - close)) / range × volume
// Bar closing at high → +v.   Closing at low → -v.   Closing at midpoint → 0.
// A green bar with a huge upper wick contributes LESS positive delta than a
// green bar that closes at its high — captures intrabar rejection without
// needing Premium-only seconds data. Direction uses rate-of-change vs N
// bars ago (responsive) instead of 20-bar SMA crossover (laggy).
float _rngCvd = high - low
float barDelta = _rngCvd > 0 ? ((close - low) - (high - close)) / _rngCvd * volume : 0.0

var float cvdTot = 0.0
if newD
    cvdTot := 0.0
cvdTot += barDelta

float cvdChange = cvdTot - nz(cvdTot[cvdLen])
int    cvdDir   = cvdChange > 0 ? 1 : cvdChange < 0 ? -1 : 0
string cvdLbl   = cvdDir > 0 ? "Rising" : cvdDir < 0 ? "Falling" : "Flat"
color  cvdCol   = cvdDir > 0 ? color.green : cvdDir < 0 ? color.maroon : color.gray

// ─── STRATEGY BIAS (Daily tactical + Weekly context) ────────────────────────
// Daily: shape + price-vs-prior-day-VA (full weight: ±2 each → ±4 max).
// Weekly: same two signals but half-weight via integer division (±1 each → ±2
// max), so only trending weekly shapes and price outside prior-week VA can
// nudge the bias. Combined range: -6…+6.
// Shape classifier — uses percentage-of-total volume in top/mid/bottom thirds
// of the price range + POC position + peak detection on a 3-bin-smoothed view.
// Requires at least 9 bins so each third has ≥3 bins (filters noise on early-
// session or narrow-range profiles).
analyzeShape(Profile p) =>
    string shp = "—"
    int    scr = 0
    if not na(p.poc) and not na(p.periodHi) and not na(p.periodLo) and p.periodHi > p.periodLo
        array<float> keys = map.keys(p.bins)
        array.sort(keys, order.ascending)
        int n = array.size(keys)
        if n >= 9
            float rng = p.periodHi - p.periodLo
            float t1  = p.periodLo + rng / 3.0
            float t2  = p.periodLo + 2.0 * rng / 3.0
            float volB = 0.0
            float volM = 0.0
            float volT = 0.0
            float gmax = 0.0
            for k in keys
                float v = map.get(p.bins, k)
                if v > gmax
                    gmax := v
                if k < t1
                    volB += v
                else if k < t2
                    volM += v
                else
                    volT += v
            float tot    = volB + volM + volT
            float topPct = tot > 0 ? volT / tot : 0.0
            float midPct = tot > 0 ? volM / tot : 0.0
            float botPct = tot > 0 ? volB / tot : 0.0
            float pocRel = (p.poc - p.periodLo) / rng

            // Peak detection: 3-bin smoothing, prominence ≥ 1.5× both neighbors,
            // height ≥ 0.55× global max. Require peaks at least 2 bins apart.
            int peaks = 0
            int lastPeakIdx = -3
            if n >= 7
                for i = 2 to n - 3
                    float s  = (map.get(p.bins, array.get(keys, i - 1)) + map.get(p.bins, array.get(keys, i)) + map.get(p.bins, array.get(keys, i + 1))) / 3.0
                    float sp = (map.get(p.bins, array.get(keys, i - 2)) + map.get(p.bins, array.get(keys, i - 1)) + map.get(p.bins, array.get(keys, i))) / 3.0
                    float sn = (map.get(p.bins, array.get(keys, i))     + map.get(p.bins, array.get(keys, i + 1)) + map.get(p.bins, array.get(keys, i + 2))) / 3.0
                    if s > 1.5 * sp and s > 1.5 * sn and s > 0.55 * gmax and i - lastPeakIdx >= 2
                        peaks += 1
                        lastPeakIdx := i

            // Classification — order matters (most restrictive first).
            if pocRel >= 0.75 and midPct <= 0.25 and topPct >= 0.40
                shp := "Trend Up"
                scr := 2
            else if pocRel <= 0.25 and midPct <= 0.25 and botPct >= 0.40
                shp := "Trend Down"
                scr := -2
            else if peaks >= 2 and midPct <= 0.25 and topPct >= 0.30 and botPct >= 0.30
                shp := "Double Dist"
                scr := topPct > botPct + 0.10 ? 1 : botPct > topPct + 0.10 ? -1 : 0
            else if topPct >= 0.45 and botPct <= 0.25 and pocRel >= 0.50
                shp := "P-Shape"
                scr := 1
            else if botPct >= 0.45 and topPct <= 0.25 and pocRel <= 0.50
                shp := "b-Shape"
                scr := -1
            else
                shp := "D-Shape"
                scr := 0
    [shp, scr]

analyzePVA(array<Profile> lst) =>
    string txt = "No prior day"
    int    scr = 0
    if array.size(lst) >= 2
        Profile prev = array.get(lst, array.size(lst) - 2)
        if not na(prev.poc) and not na(prev.vah) and not na(prev.val)
            if close > prev.vah
                txt := "Above pVAH"
                scr := 2
            else if close > prev.poc
                txt := "Upper pVA"
                scr := 1
            else if close < prev.val
                txt := "Below pVAL"
                scr := -2
            else if close < prev.poc
                txt := "Lower pVA"
                scr := -1
            else
                txt := "At pPOC"
                scr := 0
    [txt, scr]

// Range is -6…+6 (daily ±4 + weekly ±2).
biasSummary(int score) =>
    string lbl = score >=  4 ? "STRONG BULL" : score >=  1 ? "BULLISH" : score <= -4 ? "STRONG BEAR" : score <= -1 ? "BEARISH" : "NEUTRAL"
    color  col = score >=  4 ? color.lime    : score >=  1 ? color.green  : score <= -4 ? color.red     : score <= -1 ? color.maroon : color.gray
    [lbl, col]

var table biasTable = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 75), frame_color=color.new(color.gray, 50), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)

if barstate.islast
    if showBias
        Profile curD = array.get(pDList, array.size(pDList) - 1)
        Profile curW = array.get(pWkList, array.size(pWkList) - 1)
        // Recompute both here so the bias stays real-time even on ticks
        // where the render throttle skipped the profile redraw.
        curD.compute()
        curW.compute()
        [dShp, dShpScr] = analyzeShape(curD)
        [dPva, dPvaScr] = analyzePVA(pDList)
        [wShpRaw, wShpScrRaw] = analyzeShape(curW)
        [wPvaRaw, wPvaScrRaw] = analyzePVA(pWkList)
        // Weekly contribution is halved — only decisive signals (Trend / outside
        // prior-week VA) move the needle. Raw ±2 passes through as ±1; raw ±1
        // and 0 collapse to 0. (Pine's `/` is float division, so we do this
        // explicitly instead of relying on integer truncation.)
        int wShpScr = wShpScrRaw >=  2 ? 1 : wShpScrRaw <= -2 ? -1 : 0
        int wPvaScr = wPvaScrRaw >=  2 ? 1 : wPvaScrRaw <= -2 ? -1 : 0
        // Only the trending weekly shapes survive the /2 filter (Trend Up/Down).
        // Everything else is displayed as "—" to reflect it doesn't contribute.
        string wShp = wShpScr != 0 ? wShpRaw : "—"
        // Only Above-pVAH and Below-pVAL weekly readings survive /2. Relabel
        // them with "pWk" so they don't read as daily levels.
        string wPva = wPvaScr > 0 ? "Above pWkVAH" : wPvaScr < 0 ? "Below pWkVAL" : wPvaRaw == "No prior day" ? "No prior wk" : "Inside pWk VA"
        int total = dShpScr + dPvaScr + wShpScr + wPvaScr
        [lbl, col] = biasSummary(total)

        // Composite trade-signal ("GO" dashboard). Three conditions:
        //   1. Bias strength ≥ 2 (has conviction)
        //   2. Volume regime at least Normal (market is tradeable)
        //   3. CVD not opposing the bias direction (flat or aligned is OK)
        // All three green → GO. Two green → CAUTION. One or zero → WAIT.
        int biasSign = total > 0 ? 1 : total < 0 ? -1 : 0
        bool cvdAligned = cvdDir == 0 or biasSign == 0 or (biasSign > 0 and cvdDir >= 0) or (biasSign < 0 and cvdDir <= 0)
        bool volOK = volRatio >= 0.6
        bool strongBias = math.abs(total) >= 2
        int greens = (strongBias ? 1 : 0) + (volOK ? 1 : 0) + (cvdAligned ? 1 : 0)
        string sigLbl = greens == 3 ? "GO" : greens == 2 ? "CAUTION" : "WAIT"
        color  sigCol = greens == 3 ? color.lime : greens == 2 ? color.orange : color.maroon

        // Format ATR with price formatting so the pt-value reads cleanly on any symbol.
        string atrStr = str.tostring(atrVal, format.mintick) + " (≥" + str.tostring(atrVal * 1.5, format.mintick) + " stop)"

        table.cell(biasTable, 0, 0, "Bias",     text_color=color.white,  bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(biasTable, 1, 0, lbl,        text_color=color.white,  bgcolor=col,                         text_size=size.small)
        table.cell(biasTable, 0, 1, "D Shape",  text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 1, dShp,       text_color=color.white,  text_size=size.small)
        table.cell(biasTable, 0, 2, "D vs pVA", text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 2, dPva,       text_color=color.white,  text_size=size.small)
        table.cell(biasTable, 0, 3, "W Shape",  text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 3, wShp,       text_color=color.white,  text_size=size.small)
        table.cell(biasTable, 0, 4, "W vs pWk", text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 4, wPva,       text_color=color.white,  text_size=size.small)
        table.cell(biasTable, 0, 5, "Score",    text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 5, (total >= 0 ? "+" : "") + str.tostring(total), text_color=color.white, text_size=size.small)
        table.cell(biasTable, 0, 6, "ATR",      text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 6, atrStr,     text_color=color.white,  text_size=size.small)
        table.cell(biasTable, 0, 7, "Volume",   text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 7, volLbl + " " + str.tostring(volRatio, "#.##") + "x", text_color=color.white, bgcolor=volCol, text_size=size.small)
        table.cell(biasTable, 0, 8, "CVD",      text_color=color.silver, text_size=size.small)
        table.cell(biasTable, 1, 8, cvdLbl,     text_color=color.white,  bgcolor=cvdCol, text_size=size.small)
        table.cell(biasTable, 0, 9, "Signal",   text_color=color.silver, bgcolor=color.new(color.black, 50), text_size=size.small)
        table.cell(biasTable, 1, 9, sigLbl,     text_color=color.white,  bgcolor=sigCol, text_size=size.small)
    else
        table.clear(biasTable, 0, 0, 1, 9)

// ─── VWAPS ──────────────────────────────────────────────────────────────────
// Daily VWAP
var float sumPVd = 0.0
var float sumVd  = 0.0
var float sumPV2d = 0.0
if newD
    sumPVd  := 0.0
    sumVd   := 0.0
    sumPV2d := 0.0
float tpBar = (high + low + close) / 3.0
sumPVd  += tpBar * volume
sumVd   += volume
sumPV2d += tpBar * tpBar * volume
float dvwap = sumVd > 0 ? sumPVd / sumVd : na
float dvar  = sumVd > 0 ? (sumPV2d / sumVd) - (dvwap * dvwap) : na
float dstd  = dvar > 0 ? math.sqrt(dvar) : 0

plot(showDv ? dvwap : na, "Daily VWAP", color=colDv, linewidth=2)
plot(showDv and showBnd ? dvwap + dstd : na, "D +1σ", color=color.new(colDv, 60))
plot(showDv and showBnd ? dvwap - dstd : na, "D -1σ", color=color.new(colDv, 60))
plot(showDv and showBnd ? dvwap + 2*dstd : na, "D +2σ", color=color.new(colDv, 75))
plot(showDv and showBnd ? dvwap - 2*dstd : na, "D -2σ", color=color.new(colDv, 75))

// Weekly VWAP
var float sumPVw = 0.0
var float sumVw  = 0.0
var float sumPV2w = 0.0
if newWk
    sumPVw  := 0.0
    sumVw   := 0.0
    sumPV2w := 0.0
sumPVw  += tpBar * volume
sumVw   += volume
sumPV2w += tpBar * tpBar * volume
float wvwap = sumVw > 0 ? sumPVw / sumVw : na
float wvar  = sumVw > 0 ? (sumPV2w / sumVw) - (wvwap * wvwap) : na
float wstd  = wvar > 0 ? math.sqrt(wvar) : 0

plot(showWv ? wvwap : na, "Weekly VWAP", color=colWv, linewidth=2)
plot(showWv and showBnd ? wvwap + wstd : na, "W +1σ", color=color.new(colWv, 60))
plot(showWv and showBnd ? wvwap - wstd : na, "W -1σ", color=color.new(colWv, 60))
plot(showWv and showBnd ? wvwap + 2*wstd : na, "W +2σ", color=color.new(colWv, 75))
plot(showWv and showBnd ? wvwap - 2*wstd : na, "W -2σ", color=color.new(colWv, 75))

// NY Session VWAP
inNY = not na(time(timeframe.period, nySess, syminfo.timezone))
var float sumPVn = 0.0
var float sumVn  = 0.0
var float sumPV2n = 0.0
bool newNY = inNY and not inNY[1]
if newNY
    sumPVn  := 0.0
    sumVn   := 0.0
    sumPV2n := 0.0
if inNY
    sumPVn  += tpBar * volume
    sumVn   += volume
    sumPV2n += tpBar * tpBar * volume
float nvwap = inNY and sumVn > 0 ? sumPVn / sumVn : na
float nvar  = inNY and sumVn > 0 ? (sumPV2n / sumVn) - (nvwap * nvwap) : na
float nstd  = nvar > 0 ? math.sqrt(nvar) : 0

plot(showNy ? nvwap : na, "NY VWAP", color=colNy, linewidth=2)
plot(showNy and showBnd ? nvwap + nstd : na, "NY +1σ", color=color.new(colNy, 60))
plot(showNy and showBnd ? nvwap - nstd : na, "NY -1σ", color=color.new(colNy, 60))
plot(showNy and showBnd ? nvwap + 2*nstd : na, "NY +2σ", color=color.new(colNy, 75))
plot(showNy and showBnd ? nvwap - 2*nstd : na, "NY -2σ", color=color.new(colNy, 75))

// ─── INITIAL BALANCE (first-hour RTH range) ─────────────────────────────────
// Tracks the high/low of the first hour of NY cash session (default 09:30-10:30
// ET). Once the IB session ends, two horizontal lines are drawn and extend to
// the right for the remainder of the day. IB high / low are common intraday
// magnets and rejection pivots. When ibUseAsLevel is on, they feed into the
// reversal trigger detector as first-class levels.
bool _inIB   = not na(time(timeframe.period, ibSess, "America/New_York"))
bool _newIB  = _inIB and not _inIB[1]
bool _endIB  = not _inIB and _inIB[1]

var float _ibHi       = na
var float _ibLo       = na
var int   _ibStartBar = na
var line  _ibHiLine   = na
var line  _ibLoLine   = na
var label _ibHiLabel  = na
var label _ibLoLabel  = na

if _newIB
    // Fresh IB window — blow away yesterday's visuals, start accumulating
    line.delete(_ibHiLine)
    line.delete(_ibLoLine)
    label.delete(_ibHiLabel)
    label.delete(_ibLoLabel)
    _ibHiLine   := na
    _ibLoLine   := na
    _ibHiLabel  := na
    _ibLoLabel  := na
    _ibHi       := high
    _ibLo       := low
    _ibStartBar := bar_index

if _inIB and not na(_ibHi)
    _ibHi := math.max(_ibHi, high)
    _ibLo := math.min(_ibLo, low)

if _endIB and showIB and not na(_ibHi)
    _ibHiLine := line.new(_ibStartBar, _ibHi, bar_index, _ibHi, xloc=xloc.bar_index, extend=extend.right, color=ibColor, style=line.style_dashed, width=1)
    _ibLoLine := line.new(_ibStartBar, _ibLo, bar_index, _ibLo, xloc=xloc.bar_index, extend=extend.right, color=ibColor, style=line.style_dashed, width=1)
    if showLbl
        _ibHiLabel := label.new(bar_index, _ibHi, "IBH", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=ibColor, style=label.style_none, size=size.small)
        _ibLoLabel := label.new(bar_index, _ibLo, "IBL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=ibColor, style=label.style_none, size=size.small)

// IB becomes a "live" level only once the session has completed
bool _ibLive = not _inIB and not na(_ibHi) and not na(_ibLo)

// ─── REVERSAL TRIGGER AT LEVELS (single GO signal, latched) ─────────────────
// One rule, no pattern taxonomy. Fires on bar X when:
//   1. Bar X-1 touched a level (POC/VAH/VAL on Mo/Wk/D profiles, or a VWAP)
//      — this is the rejection/interaction bar (could be pin, doji, engulf, anything)
//   2. Bar X has a real body (body/range ≥ trigBodyPct) — commits, not chops
//   3. Bar X closes past bar X-1's extreme:
//        Bull: close > high[1]  → rejection confirmed, go long
//        Bear: close < low[1]   → rejection confirmed, go short
//   4. LATCH: only the first matching bar in each level-approach fires. After
//      firing, no same-direction arrow until price has fully left all level
//      zones (two consecutive bars not touching any level). Opposite direction
//      can still fire at the same zone.
// Captures bullish/bearish engulfing, hammer+confirm, shooting-star+confirm,
// and doji-break-out automatically — because the commit rule subsumes them all.
bodyCur = math.abs(close - open)
rngCur  = high - low
isGrn   = close > open
isRed   = close < open

bool strongBody = rngCur > 0 and bodyCur / rngCur >= trigBodyPct

// Level touch for an arbitrary offset. Profile levels are quasi-static within
// a period, so referencing current lvl with high[o]/low[o] is correct.
touchedAt(float lvl, int o) =>
    not na(lvl) and high[o] >= lvl - engulfLevelDist and low[o] <= lvl + engulfLevelDist

touchedProfileAt(Profile p, int o) =>
    touchedAt(p.poc, o) or touchedAt(p.vah, o) or touchedAt(p.val, o)

touchedListAt(array<Profile> lst, bool incPrior, int o) =>
    bool t = false
    int sz = array.size(lst)
    if sz > 0
        t := t or touchedProfileAt(array.get(lst, sz - 1), o)
        if incPrior
            for i = 0 to sz - 2
                t := t or touchedProfileAt(array.get(lst, i), o)
    t

atLvlOffset(int o) =>
    bool t = false
    t := t or touchedListAt(pDList,  showPrevD  and showD,  o)
    t := t or touchedListAt(pWkList, showPrevWk and showWk, o)
    t := t or touchedListAt(pMoList, showPrevMo and showMo, o)
    t := t or (showDv and touchedAt(dvwap, o))
    t := t or (showWv and touchedAt(wvwap, o))
    t := t or (showNy and touchedAt(nvwap, o))
    t := t or (ibUseAsLevel and showIB and _ibLive and touchedAt(_ibHi, o))
    t := t or (ibUseAsLevel and showIB and _ibLive and touchedAt(_ibLo, o))
    t

bool currAtLvl = atLvlOffset(0)
bool prevAtLvl = atLvlOffset(1)

// Returns highest-priority level type touched by the prior bar:
//   3 = VWAP or current-Daily POC   2 = D VAH/VAL, W POC, IB hi/lo
//   1 = anything else that qualified as 'at level'   0 = none
prevLvlPriority() =>
    int p = 0
    if (showDv and touchedAt(dvwap, 1)) or (showWv and touchedAt(wvwap, 1)) or (showNy and touchedAt(nvwap, 1))
        p := math.max(p, 3)
    if array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        if touchedAt(cD.poc, 1)
            p := math.max(p, 3)
        if touchedAt(cD.vah, 1) or touchedAt(cD.val, 1)
            p := math.max(p, 2)
    if array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        if touchedAt(cW.poc, 1)
            p := math.max(p, 2)
    if ibUseAsLevel and showIB and _ibLive and (touchedAt(_ibHi, 1) or touchedAt(_ibLo, 1))
        p := math.max(p, 2)
    if prevAtLvl and p == 0
        p := 1
    p

// Collect every live level into a sorted array — used to project TPs.
collectAllLvls() =>
    array<float> lvls = array.new<float>()
    if showDv and not na(dvwap)
        array.push(lvls, dvwap)
    if showWv and not na(wvwap)
        array.push(lvls, wvwap)
    if showNy and not na(nvwap) and inNY
        array.push(lvls, nvwap)
    if array.size(pDList) > 0
        for i = 0 to array.size(pDList) - 1
            Profile p = array.get(pDList, i)
            if not na(p.poc)
                array.push(lvls, p.poc)
            if not na(p.vah)
                array.push(lvls, p.vah)
            if not na(p.val)
                array.push(lvls, p.val)
    if array.size(pWkList) > 0
        for i = 0 to array.size(pWkList) - 1
            Profile p = array.get(pWkList, i)
            if not na(p.poc)
                array.push(lvls, p.poc)
            if not na(p.vah)
                array.push(lvls, p.vah)
            if not na(p.val)
                array.push(lvls, p.val)
    if showIB and _ibLive
        if not na(_ibHi)
            array.push(lvls, _ibHi)
        if not na(_ibLo)
            array.push(lvls, _ibLo)
    array.sort(lvls, order.ascending)
    lvls

nextLvlAbove(float px, array<float> lvls, int skip) =>
    int count = 0
    float r = na
    int n = array.size(lvls)
    if n > 0
        for i = 0 to n - 1
            float v = array.get(lvls, i)
            if v > px + syminfo.mintick * 2
                if count == skip and na(r)
                    r := v
                count += 1
    r

nextLvlBelow(float px, array<float> lvls, int skip) =>
    int count = 0
    float r = na
    int n = array.size(lvls)
    if n > 0
        for k = 0 to n - 1
            int i = n - 1 - k
            float v = array.get(lvls, i)
            if v < px - syminfo.mintick * 2
                if count == skip and na(r)
                    r := v
                count += 1
    r

// Latches — clear when price has fully left all levels for 2 bars running
var bool _bullLatched = false
var bool _bearLatched = false
if not currAtLvl and not prevAtLvl
    _bullLatched := false
    _bearLatched := false

// Cooldown tracking — bar_index of last fired signal per direction.
// Initialized to -9999 so no cooldown is active at script start.
var int _bullCooldownBar = -9999
var int _bearCooldownBar = -9999

// ─── FAIR VALUE GAP TRACKING (for IFVG detection) ────────────────────────────
// Bullish FVG: high[2] < low (3-bar gap up). Bearish FVG: low[2] > high (3-bar gap down).
// IFVG fires when price fills the gap and shows a reaction.
var float _fvgBullTop = na
var float _fvgBullBot = na
var int   _fvgBullBar = 0
var float _fvgBearTop = na
var float _fvgBearBot = na
var int   _fvgBearBar = 0

if not na(high[2]) and low > high[2]
    _fvgBullTop := low
    _fvgBullBot := high[2]
    _fvgBullBar := bar_index
if not na(low[2]) and high < low[2]
    _fvgBearTop := low[2]
    _fvgBearBot := high
    _fvgBearBar := bar_index

// ─── KILL ZONE / BIAS / CLUSTER (shared by engine detectors and grade) ────────
// Kill zones: 09:30-11:30 and 13:30-15:00 ET — highest-probability reversal windows.
bool _inKill = not na(time(timeframe.period, "0930-1130", "America/New_York")) or not na(time(timeframe.period, "1330-1500", "America/New_York"))
// Per-bar PVA bias score (±2)
[_pvaTxtG, _pvaScrG] = analyzePVA(pDList)
// Is current price inside any highlighted cluster box?
bool _inCluster = false
if array.size(clusterBoxes) > 0
    for i = 0 to array.size(clusterBoxes) - 1
        box bx = array.get(clusterBoxes, i)
        float bTop = box.get_top(bx)
        float bBot = box.get_bottom(bx)
        if close >= bBot and close <= bTop
            _inCluster := true

// ─── SETUP ENGINE CONTEXT ─────────────────────────────────────────────────────
// Profile levels (latest period)
float _epDPOC = array.size(pDList)  > 0 ? array.get(pDList,  array.size(pDList)  - 1).poc : na
float _epDVAH = array.size(pDList)  > 0 ? array.get(pDList,  array.size(pDList)  - 1).vah : na
float _epDVAL = array.size(pDList)  > 0 ? array.get(pDList,  array.size(pDList)  - 1).val : na
float _epWVAH = array.size(pWkList) > 0 ? array.get(pWkList, array.size(pWkList) - 1).vah : na
float _epWVAL = array.size(pWkList) > 0 ? array.get(pWkList, array.size(pWkList) - 1).val : na

// HTF bias proxy (kept as-is — detection functions reference these booleans)
bool _htfBull = _pvaScrG >= 1 or (_pvaScrG == 0 and cvdDir > 0)
bool _htfBear = _pvaScrG <= -1 or (_pvaScrG == 0 and cvdDir < 0)

// ─── HTF BIAS SCORING — Phase 1: PVA + CVD ───────────────────────────────────
// Scored 0–9 per direction. Used for grade weighting and counter-trend detection.
// Does NOT block trades — only weights confirmation requirements and grade.
int _longBiasScore  = 0
int _shortBiasScore = 0
// PVA contribution
if _pvaScrG >= 2
    _longBiasScore  += 3
else if _pvaScrG == 1
    _longBiasScore  += 1
else if _pvaScrG == -1
    _shortBiasScore += 1
else if _pvaScrG <= -2
    _shortBiasScore += 3
// CVD contribution
if cvdDir > 0
    _longBiasScore  += 1
else if cvdDir < 0
    _shortBiasScore += 1
// Phase 2 bonuses added below after price-location booleans are defined

// Price location relative to value area
bool _aboveDVAH       = not na(_epDVAH) and close > _epDVAH + engulfLevelDist * 0.3
bool _belowDVAL       = not na(_epDVAL) and close < _epDVAL - engulfLevelDist * 0.3
bool _twoBarAboveDVAH = _aboveDVAH and not na(_epDVAH) and close[1] > _epDVAH - engulfLevelDist
bool _twoBarBelowDVAL = _belowDVAL and not na(_epDVAL) and close[1] < _epDVAL + engulfLevelDist
bool _priorBelowDVAL  = not na(_epDVAL) and close[1] < _epDVAL and close[2] < _epDVAL
bool _priorAboveDVAH  = not na(_epDVAH) and close[1] > _epDVAH and close[2] > _epDVAH
bool _failedBullBreak = not na(_epDVAH) and close < _epDVAH and (close[1] > _epDVAH or close[2] > _epDVAH)
bool _failedBearBreak = not na(_epDVAL) and close > _epDVAL and (close[1] < _epDVAL or close[2] < _epDVAL)

// ─── HTF BIAS SCORING — Phase 2: price-location + failed-break bonuses ───────
// Weekly value area alignment
if not na(_epWVAH) and close > _epWVAH
    _longBiasScore  += 2
else if not na(_epWVAL) and close < _epWVAL
    _shortBiasScore += 2
// Daily: price above/below daily POC = mild directional lean
if not na(_epDPOC)
    if close > _epDPOC + engulfLevelDist * 0.3
        _longBiasScore  += 1
    else if close < _epDPOC - engulfLevelDist * 0.3
        _shortBiasScore += 1
// Failed-break bonuses (trapped traders = potential momentum)
if _failedBullBreak
    _shortBiasScore += 2
if _failedBearBreak
    _longBiasScore  += 2
// Two-bar acceptance bonus
if _twoBarAboveDVAH
    _longBiasScore  += 1
if _twoBarBelowDVAL
    _shortBiasScore += 1
// Bias state string (for debug table)
string _biasState = _longBiasScore  >= 6 ? "BULL"
  : _shortBiasScore >= 6             ? "BEAR"
  : _longBiasScore  >= 3             ? "lean_bull"
  : _shortBiasScore >= 3             ? "lean_bear"
  : "neutral"

// Mean reversion context
float _pocDistAtr  = not na(_epDPOC) and atrVal > 0 ? math.abs(close - _epDPOC) / atrVal : 999.0
bool  _farBelowPOC = not na(_epDPOC) and close < _epDPOC and _pocDistAtr >= 1.5
bool  _farAbovePOC = not na(_epDPOC) and close > _epDPOC and _pocDistAtr >= 1.5
float _dvwapSigma  = not na(dvwap) and dstd > 0 ? (close - dvwap) / dstd : 0.0

// Candle shape helpers
float _bullFrac = rngCur > 0 ? (close - low)  / rngCur : 0.5   // 1.0 = closes at high
float _bearFrac = rngCur > 0 ? (high - close) / rngCur : 0.5   // 1.0 = closes at low
float _bodyFrac = rngCur > 0 ? bodyCur / rngCur : 0.0

// Commit conditions (engulf core)
bool _bullCommit = isGrn and strongBody and close > high[1]
bool _bearCommit = isRed and strongBody and close < low[1]

// CSD: displacement through prior candle body
bool _csdBullConf = open[1] > close[1] and close > open[1]
bool _csdBullForm = open[1] > close[1] and close > (open[1] + close[1]) * 0.5
bool _csdBearConf = open[1] < close[1] and close < open[1]
bool _csdBearForm = open[1] < close[1] and close < (open[1] + close[1]) * 0.5

// rawBull / rawBear / goBull / goBear are defined after detection functions below.

// ─── GRADING ──────────────────────────────────────────────────────────────────
// Grade scoring per direction: sign flips for bear so positive = aligned with trade dir.
computeGrade(int dir) =>
    int lvlP = prevLvlPriority()
    int lvlScr = lvlP >= 3 ? 2 : lvlP >= 2 ? 1 : lvlP >= 1 ? 0 : 0
    int biasScr = _pvaScrG * dir                               // ±2 aligned, 0 neutral, ∓2 opposed (after dir flip)
    int volScr  = volRatio >= 2.0 ? 1 : volRatio < 0.7 ? -1 : 0
    int cvdScr  = cvdDir * dir                                 // +1 aligned, -1 opposed, 0 flat
    int killScr = _inKill ? 1 : 0
    int clusScr = _inCluster ? 2 : 0
    lvlScr + biasScr + volScr + cvdScr + killScr + clusScr

// Extends computeGrade() with a +patternBonus for high-confidence patterns.
computeGradeExt(int dir, int patternBonus) =>
    computeGrade(dir) + patternBonus

// _bullGrade / _bearGrade defined after goBull/goBear below.

gradeLetter(int score) => score >= 5 ? "A" : score >= 2 ? "B" : "C"

// Scalp-weighted composite grade: 20% bias + 30% location + 30% confirmation + 20% entry quality
// biasScore = direction-aligned score (_longBiasScore for bull, _shortBiasScore for bear)
// Returns grade token: 7 (A ≥80), 3 (B ≥65), 1 (C ≥50), 0 (blocked / no signal)
computeScalpGrade(int biasScore, int confirmCount, float stopDist) =>
    // Bias component 0–20: score 8+ = full 20pts
    int biasCmp  = int(math.min(float(biasScore) * 2.5, 20.0))
    // Location component 0–30: based on level priority
    int lvlP     = prevLvlPriority()
    int locCmp   = lvlP >= 3 ? 30 : lvlP >= 2 ? 20 : lvlP >= 1 ? 10 : 0
    // Confirmation component 0–30: 4 confirms = max
    int confCmp  = int(math.min(float(confirmCount) / 4.0 * 30.0, 30.0))
    // Entry quality component 0–20: stop at/below preferred = full 20pts
    float _eqSlope = maxStopPoints > prefStopPoints ? (maxStopPoints - stopDist) / (maxStopPoints - prefStopPoints) : 0.5
    float _eqRaw   = stopDist <= 0.0 or stopDist > maxStopPoints ? 0.0 : stopDist <= prefStopPoints ? 1.0 : _eqSlope
    int entCmp   = int(_eqRaw * 20.0)
    int total    = biasCmp + locCmp + confCmp + entCmp
    total >= 80 ? 7 : total >= 65 ? 3 : total >= 50 ? 1 : 0

// ─── EARLY SIGNAL HELPERS ─────────────────────────────────────────────────────
// All functions defined here — Pine requires definitions before first call.

// Level priority of the CURRENT bar (offset 0). Mirrors prevLvlPriority() but
// scans [0] instead of [1]. Used by computeEarlyGrade().
earlyLvlPriority() =>
    int p = 0
    if (showDv and touchedAt(dvwap, 0)) or (showWv and touchedAt(wvwap, 0)) or (showNy and touchedAt(nvwap, 0))
        p := math.max(p, 3)
    if array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        if touchedAt(cD.poc, 0)
            p := math.max(p, 3)
        if touchedAt(cD.vah, 0) or touchedAt(cD.val, 0)
            p := math.max(p, 2)
    if array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        if touchedAt(cW.poc, 0)
            p := math.max(p, 2)
    if ibUseAsLevel and showIB and _ibLive and (touchedAt(_ibHi, 0) or touchedAt(_ibLo, 0))
        p := math.max(p, 2)
    if currAtLvl and p == 0
        p := 1
    p

// Same grade formula as computeGrade() but uses earlyLvlPriority() (current bar).
computeEarlyGrade(int dir) =>
    int lvlP    = earlyLvlPriority()
    int lvlScr  = lvlP >= 3 ? 2 : lvlP >= 2 ? 1 : 0
    int biasScr = _pvaScrG * dir
    int volScr  = volRatio >= 2.0 ? 1 : volRatio < 0.7 ? -1 : 0
    int cvdScr  = cvdDir * dir
    int killScr = _inKill ? 1 : 0
    int clusScr = _inCluster ? 2 : 0
    lvlScr + biasScr + volScr + cvdScr + killScr + clusScr

// True if current bar touches any D, W, or M profile level. Used when
// earlyReqHTFZone=true to exclude VWAPs and IB from early signal eligibility.
earlyAtHTFZone() =>
    bool t = false
    int szD = array.size(pDList)
    if szD > 0
        for i = 0 to szD - 1
            t := t or touchedProfileAt(array.get(pDList, i), 0)
    int szW = array.size(pWkList)
    if szW > 0
        for i = 0 to szW - 1
            t := t or touchedProfileAt(array.get(pWkList, i), 0)
    int szM = array.size(pMoList)
    if szM > 0
        for i = 0 to szM - 1
            t := t or touchedProfileAt(array.get(pMoList, i), 0)
    t

// Liquidity sweep check: prior bar's low pierced BELOW the nearest D/W support zone.
// "Stops taken below" is a classic sweep signal for long setups.
checkEarlySweepBull() =>
    bool sw = false
    if array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        if not na(cD.val)
            sw := sw or (low[1] < cD.val - engulfLevelDist * 0.5)
        if not na(cD.poc)
            sw := sw or (low[1] < cD.poc - engulfLevelDist * 0.5)
    if array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        if not na(cW.val)
            sw := sw or (low[1] < cW.val - engulfLevelDist * 0.5)
    sw

// Liquidity sweep check: prior bar's high pierced ABOVE the nearest D/W resistance zone.
checkEarlySweepBear() =>
    bool sw = false
    if array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        if not na(cD.vah)
            sw := sw or (high[1] > cD.vah + engulfLevelDist * 0.5)
        if not na(cD.poc)
            sw := sw or (high[1] > cD.poc + engulfLevelDist * 0.5)
    if array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        if not na(cW.vah)
            sw := sw or (high[1] > cW.vah + engulfLevelDist * 0.5)
    sw

// Zone label for the current bar (offset 0). Mirrors zoneTouchedLabel() but for [0].
// Used in the early webhook JSON payload.
earlyZoneLabel() =>
    string z = ""
    if array.size(pMoList) > 0
        Profile cM = array.get(pMoList, array.size(pMoList) - 1)
        z := touchedAt(cM.poc, 0) ? "PM POC" : touchedAt(cM.vah, 0) ? "PM VAH" : touchedAt(cM.val, 0) ? "PM VAL" : z
    if z == "" and array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        z := touchedAt(cW.poc, 0) ? "PW POC" : touchedAt(cW.vah, 0) ? "PW VAH" : touchedAt(cW.val, 0) ? "PW VAL" : z
    if z == "" and array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        z := touchedAt(cD.poc, 0) ? "PD POC" : touchedAt(cD.vah, 0) ? "PD VAH" : touchedAt(cD.val, 0) ? "PD VAL" : z
    if z == "" and showDv and touchedAt(dvwap, 0)
        z := "VWAP D"
    if z == "" and showWv and touchedAt(wvwap, 0)
        z := "VWAP W"
    if z == "" and showNy and touchedAt(nvwap, 0)
        z := "VWAP NY"
    if z == "" and ibUseAsLevel and showIB and _ibLive
        z := touchedAt(_ibHi, 0) ? "IB High" : touchedAt(_ibLo, 0) ? "IB Low" : z
    z == "" ? "level" : z

// Grade filter: true if score meets the minimum grade threshold set by the user.
earlyGradeMet(int score) =>
    earlyMinGrade == "A" ? score >= 5 : earlyMinGrade == "B" ? score >= 2 : true

// ─── PATTERN DETECTION FUNCTIONS ─────────────────────────────────────────────
// Each returns [detected, score, confType].
// Outer context vars (_htfBull, _inKill, _bullCommit, etc.) are resolved at
// call time from the main script body — set before these functions are called.

// ── Breakout Long ──────────────────────────────────────────────────────────────
detectBreakoutLong() =>
    bool   d  = false
    int    s  = 0
    string ct = "breakout_acceptance"
    int    ms = math.max(4, minPatternScore)
    if _aboveDVAH
        d := true
        s += 2
        if _twoBarAboveDVAH
            s += 2
        if _bodyFrac >= 0.55
            s += 1
        if bodyCur >= atrVal * 0.4
            s += 1
            ct := "displacement_through"
        if volRatio >= 1.3
            s += 1
        if cvdDir > 0
            s += 1
        if not na(_epWVAH) and close > _epWVAH
            s += 1
        if _htfBear
            s -= 2
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Breakout Short ────────────────────────────────────────────────────────────
detectBreakoutShort() =>
    bool   d  = false
    int    s  = 0
    string ct = "breakout_acceptance"
    int    ms = math.max(4, minPatternScore)
    if _belowDVAL
        d := true
        s += 2
        if _twoBarBelowDVAL
            s += 2
        if _bodyFrac >= 0.55
            s += 1
        if bodyCur >= atrVal * 0.4
            s += 1
            ct := "displacement_through"
        if volRatio >= 1.3
            s += 1
        if cvdDir < 0
            s += 1
        if not na(_epWVAL) and close < _epWVAL
            s += 1
        if _htfBull
            s -= 2
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Continuation Long ─────────────────────────────────────────────────────────
detectContinuationLong() =>
    bool   d  = false
    int    s  = 0
    string ct = "rejection_at_support"
    int    ms = math.max(4, minPatternScore)
    if _htfBull and prevAtLvl
        d := true
        s += 2
        if _bullCommit
            s += 2
            ct := "reclaim_above_level"
        else if isGrn and _bullFrac >= 0.50
            s += 1
        if checkEarlySweepBull()
            s += 2
            ct := "sweep_reclaim"
        if not na(_epDVAL) and close >= _epDVAL and close <= _epDVAL + engulfLevelDist * 2
            s += 1
        if cvdDir >= 0
            s += 1
        if volRatio >= 0.7
            s += 1
        if _inKill
            s += 1
        if _inCluster
            s += 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Continuation Short ────────────────────────────────────────────────────────
detectContinuationShort() =>
    bool   d  = false
    int    s  = 0
    string ct = "rejection_at_resistance"
    int    ms = math.max(4, minPatternScore)
    if _htfBear and prevAtLvl
        d := true
        s += 2
        if _bearCommit
            s += 2
            ct := "reclaim_below_level"
        else if isRed and _bearFrac >= 0.50
            s += 1
        if checkEarlySweepBear()
            s += 2
            ct := "sweep_reclaim"
        if not na(_epDVAH) and close <= _epDVAH and close >= _epDVAH - engulfLevelDist * 2
            s += 1
        if cvdDir <= 0
            s += 1
        if volRatio >= 0.7
            s += 1
        if _inKill
            s += 1
        if _inCluster
            s += 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Reversal Long (closest to original engulf logic) ─────────────────────────
detectReversalLong() =>
    bool   d  = false
    int    s  = 0
    string ct = "structure_shift_bullish"
    int    ms = math.max(5, minPatternScore)
    if _priorBelowDVAL and prevAtLvl
        d := true
        s += 2
        if checkEarlySweepBull()
            s += 2
            ct := "failed_acceptance_below"
        if _bullCommit
            s += 2
            ct := "structure_shift_bullish"
        if not na(_epDVAL) and close > _epDVAL
            s += 1
            ct := "reclaim_above_value"
        if cvdDir > 0
            s += 1
        if _inKill
            s += 1
        if _inCluster
            s += 1
        if _htfBear
            s -= 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Reversal Short ────────────────────────────────────────────────────────────
detectReversalShort() =>
    bool   d  = false
    int    s  = 0
    string ct = "structure_shift_bearish"
    int    ms = math.max(5, minPatternScore)
    if _priorAboveDVAH and prevAtLvl
        d := true
        s += 2
        if checkEarlySweepBear()
            s += 2
            ct := "failed_acceptance_above"
        if _bearCommit
            s += 2
            ct := "structure_shift_bearish"
        if not na(_epDVAH) and close < _epDVAH
            s += 1
            ct := "reclaim_below_value"
        if cvdDir < 0
            s += 1
        if _inKill
            s += 1
        if _inCluster
            s += 1
        if _htfBull
            s -= 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Mean Reversion Long ───────────────────────────────────────────────────────
detectMeanReversionLong() =>
    bool   d  = false
    int    s  = 0
    string ct = "mean_reversion_attempt"
    int    ms = math.max(5, minPatternScore)
    if _farBelowPOC or _dvwapSigma <= -1.5
        d := true
        s += 2
        if isGrn and _bullFrac >= 0.45
            s += 2
        if _bullCommit
            s += 1
        if volRatio >= 1.5
            s += 2
            ct := "volume_spike_reversal"
        if cvdDir > 0
            s += 1
        if _dvwapSigma <= -2.0
            s += 1
            ct := "vwap_2sigma_reversion"
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Mean Reversion Short ──────────────────────────────────────────────────────
detectMeanReversionShort() =>
    bool   d  = false
    int    s  = 0
    string ct = "mean_reversion_attempt"
    int    ms = math.max(5, minPatternScore)
    if _farAbovePOC or _dvwapSigma >= 1.5
        d := true
        s += 2
        if isRed and _bearFrac >= 0.45
            s += 2
        if _bearCommit
            s += 1
        if volRatio >= 1.5
            s += 2
            ct := "volume_spike_reversal"
        if cvdDir < 0
            s += 1
        if _dvwapSigma >= 2.0
            s += 1
            ct := "vwap_2sigma_reversion"
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Failed Breakout Long (trapped shorts recovering) ─────────────────────────
detectFailedBreakoutLong() =>
    bool   d  = false
    int    s  = 0
    string ct = "false_breakdown_recovery"
    int    ms = math.max(5, minPatternScore)
    if _failedBearBreak
        d := true
        s += 3
        if checkEarlySweepBull()
            s += 2
        if _bullCommit
            s += 2
            ct := "false_breakdown_engulf"
        if _bodyFrac >= 0.55
            s += 1
        if volRatio >= 1.3
            s += 1
        if cvdDir > 0
            s += 1
        if _inKill
            s += 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Failed Breakout Short (trapped longs rolling over) ───────────────────────
detectFailedBreakoutShort() =>
    bool   d  = false
    int    s  = 0
    string ct = "false_breakout_recovery"
    int    ms = math.max(5, minPatternScore)
    if _failedBullBreak
        d := true
        s += 3
        if checkEarlySweepBear()
            s += 2
        if _bearCommit
            s += 2
            ct := "false_breakout_engulf"
        if _bodyFrac >= 0.55
            s += 1
        if volRatio >= 1.3
            s += 1
        if cvdDir < 0
            s += 1
        if _inKill
            s += 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── Sweep + Reclaim ───────────────────────────────────────────────────────────
detectSweepReclaim(int dir) =>
    bool   d  = false
    int    s  = 0
    string ct = "sweep_reclaim_attempt"
    int    ms = math.max(5, minPatternScore)
    if dir == 1
        if checkEarlySweepBull() and prevAtLvl
            d := true
            s += 4
            if _bullCommit
                s += 2
                ct := "sweep_engulf_reclaim"
            else if isGrn and _bullFrac >= 0.45
                s += 1
            if cvdDir >= 0
                s += 1
            if volRatio >= 1.3
                s += 1
    else
        if checkEarlySweepBear() and prevAtLvl
            d := true
            s += 4
            if _bearCommit
                s += 2
                ct := "sweep_engulf_reclaim"
            else if isRed and _bearFrac >= 0.45
                s += 1
            if cvdDir <= 0
                s += 1
            if volRatio >= 1.3
                s += 1
    if not d or s < ms
        d := false
        s := 0
    [d, s, ct]

// ── CSD — Candle Structural Displacement ─────────────────────────────────────
detectCSD(int dir) =>
    bool   d  = false
    int    s  = 0
    string ct = ""
    if dir == 1
        if _csdBullConf
            d  := true
            s  += 4
            ct := "csd_confirmed_long"
        else if _csdBullForm
            d  := true
            s  += 2
            ct := "csd_forming_long"
        if d
            if prevAtLvl
                s += 1
            if cvdDir > 0
                s += 1
    else
        if _csdBearConf
            d  := true
            s  += 4
            ct := "csd_confirmed_short"
        else if _csdBearForm
            d  := true
            s  += 2
            ct := "csd_forming_short"
        if d
            if prevAtLvl
                s += 1
            if cvdDir < 0
                s += 1
    if not d or s < minPatternScore
        d := false
        s := 0
    [d, s, ct]

// ── IFVG — Inverse Fair Value Gap reaction ────────────────────────────────────
detectIFVG(int dir) =>
    bool   d  = false
    int    s  = 0
    string ct = ""
    if dir == 1
        int  fvgAge = not na(_fvgBullTop) ? bar_index - _fvgBullBar : 999
        bool inGap  = not na(_fvgBullTop) and fvgAge <= 30 and high[1] <= _fvgBullTop and low[1] >= _fvgBullBot
        if inGap
            d  := true
            s  += 3
            ct := close > _fvgBullTop ? "ifvg_bullish_reaction" : "ifvg_bullish_touch"
            if close > _fvgBullTop
                s += 2
            if cvdDir > 0
                s += 1
    else
        int  fvgAge = not na(_fvgBearTop) ? bar_index - _fvgBearBar : 999
        bool inGap  = not na(_fvgBearTop) and fvgAge <= 30 and low[1] >= _fvgBearBot and high[1] <= _fvgBearTop
        if inGap
            d  := true
            s  += 3
            ct := close < _fvgBearBot ? "ifvg_bearish_reaction" : "ifvg_bearish_touch"
            if close < _fvgBearBot
                s += 2
            if cvdDir < 0
                s += 1
    if not d or s < minPatternScore
        d := false
        s := 0
    [d, s, ct]

// ── Acceptance above/below value area ────────────────────────────────────────
detectAcceptance(int dir) =>
    bool   d  = false
    int    s  = 0
    string ct = ""
    if dir == 1
        if _twoBarAboveDVAH
            d  := true
            s  += 3
            ct := "accepting_above_vah"
            if not na(_epDVAH) and close[2] > _epDVAH - engulfLevelDist
                s += 1
            if cvdDir > 0
                s += 1
    else
        if _twoBarBelowDVAL
            d  := true
            s  += 3
            ct := "accepting_below_val"
            if not na(_epDVAL) and close[2] < _epDVAL + engulfLevelDist
                s += 1
            if cvdDir < 0
                s += 1
    if not d or s < minPatternScore
        d := false
        s := 0
    [d, s, ct]

// ── Wick rejection at level ───────────────────────────────────────────────────
detectRejection(int dir) =>
    bool   d  = false
    int    s  = 0
    string ct = ""
    float  rng1 = high[1] - low[1]
    if dir == 1
        float lowerWick = rng1 > 0 ? (close[1] - low[1]) / rng1 : 0.0
        if prevAtLvl and lowerWick >= 0.4 and isGrn
            d  := true
            s  += 2
            ct := "lower_wick_rejection"
            if _bullFrac >= 0.6
                s += 1
            if cvdDir > 0
                s += 1
    else
        float upperWick = rng1 > 0 ? (high[1] - close[1]) / rng1 : 0.0
        if prevAtLvl and upperWick >= 0.4 and isRed
            d  := true
            s  += 2
            ct := "upper_wick_rejection"
            if _bearFrac >= 0.6
                s += 1
            if cvdDir < 0
                s += 1
    if not d or s < minPatternScore
        d := false
        s := 0
    [d, s, ct]

// ─── PATTERN EVALUATION ENGINE ────────────────────────────────────────────────
// Runs all enabled detectors, selects highest-scoring pattern per direction,
// produces rawBull/rawBear that feed the latch → goBull/goBear → grade pipeline.

// Bull detectors — always called; enable flags applied in scoring loop below
// (Pine v5 does not allow ternary operators returning tuples)
[_brkL_d, _brkL_s, _brkL_ct]   = detectBreakoutLong()
[_ctL_d,  _ctL_s,  _ctL_ct]    = detectContinuationLong()
[_rvL_d,  _rvL_s,  _rvL_ct]    = detectReversalLong()
[_mrL_d,  _mrL_s,  _mrL_ct]    = detectMeanReversionLong()
[_fbL_d,  _fbL_s,  _fbL_ct]    = detectFailedBreakoutLong()
[_swL_d,  _swL_s,  _swL_ct]    = detectSweepReclaim(1)
[_csdL_d, _csdL_s, _csdL_ct]   = detectCSD(1)
[_ifvgL_d,_ifvgL_s,_ifvgL_ct]  = detectIFVG(1)
[_accL_d, _accL_s, _accL_ct]   = detectAcceptance(1)
[_rejL_d, _rejL_s, _rejL_ct]   = detectRejection(1)

// Bear detectors — always called; enable flags applied in scoring loop below
[_brkS_d, _brkS_s, _brkS_ct]   = detectBreakoutShort()
[_ctS_d,  _ctS_s,  _ctS_ct]    = detectContinuationShort()
[_rvS_d,  _rvS_s,  _rvS_ct]    = detectReversalShort()
[_mrS_d,  _mrS_s,  _mrS_ct]    = detectMeanReversionShort()
[_fbS_d,  _fbS_s,  _fbS_ct]    = detectFailedBreakoutShort()
[_swS_d,  _swS_s,  _swS_ct]    = detectSweepReclaim(-1)
[_csdS_d, _csdS_s, _csdS_ct]   = detectCSD(-1)
[_ifvgS_d,_ifvgS_s,_ifvgS_ct]  = detectIFVG(-1)
[_accS_d, _accS_s, _accS_ct]   = detectAcceptance(-1)
[_rejS_d, _rejS_s, _rejS_ct]   = detectRejection(-1)

// Select best bull pattern
int    _bullEngScore  = 0
string _bullSetupType = "none"
string _bullConfType  = "none"
string _bullConfStack = ""

if enableBreakoutSetups and _brkL_d and _brkL_s >= minPatternScore
    if _brkL_s > _bullEngScore
        _bullEngScore  := _brkL_s
        _bullSetupType := "breakout"
        _bullConfType  := _brkL_ct
    _bullConfStack := _bullConfStack == "" ? "breakout" : _bullConfStack + ",breakout"
if enableContSetups and _ctL_d and _ctL_s >= minPatternScore
    if _ctL_s > _bullEngScore
        _bullEngScore  := _ctL_s
        _bullSetupType := "continuation"
        _bullConfType  := _ctL_ct
    _bullConfStack := _bullConfStack == "" ? "continuation" : _bullConfStack + ",continuation"
if enableRevSetups and _rvL_d and _rvL_s >= minPatternScore
    if _rvL_s > _bullEngScore
        _bullEngScore  := _rvL_s
        _bullSetupType := "reversal"
        _bullConfType  := _rvL_ct
    _bullConfStack := _bullConfStack == "" ? "reversal" : _bullConfStack + ",reversal"
if enableMRSetups and _mrL_d and _mrL_s >= minPatternScore
    if _mrL_s > _bullEngScore
        _bullEngScore  := _mrL_s
        _bullSetupType := "mean_reversion"
        _bullConfType  := _mrL_ct
    _bullConfStack := _bullConfStack == "" ? "mean_reversion" : _bullConfStack + ",mean_reversion"
if enableFBSetups and _fbL_d and _fbL_s >= minPatternScore
    if _fbL_s > _bullEngScore
        _bullEngScore  := _fbL_s
        _bullSetupType := "failed_breakout"
        _bullConfType  := _fbL_ct
    _bullConfStack := _bullConfStack == "" ? "failed_breakout" : _bullConfStack + ",failed_breakout"
if _swL_d and _swL_s >= minPatternScore
    if _swL_s > _bullEngScore
        _bullEngScore  := _swL_s
        _bullSetupType := "sweep_reclaim"
        _bullConfType  := _swL_ct
    _bullConfStack := _bullConfStack == "" ? "sweep" : _bullConfStack + ",sweep"
if _csdL_d and _csdL_s >= minPatternScore
    if _csdL_s > _bullEngScore
        _bullEngScore  := _csdL_s
        _bullSetupType := "csd"
        _bullConfType  := _csdL_ct
    _bullConfStack := _bullConfStack == "" ? "csd" : _bullConfStack + ",csd"
if _ifvgL_d and _ifvgL_s >= minPatternScore
    if _ifvgL_s > _bullEngScore
        _bullEngScore  := _ifvgL_s
        _bullSetupType := "ifvg"
        _bullConfType  := _ifvgL_ct
    _bullConfStack := _bullConfStack == "" ? "ifvg" : _bullConfStack + ",ifvg"
if _accL_d and _accL_s >= minPatternScore
    if _accL_s > _bullEngScore
        _bullEngScore  := _accL_s
        _bullSetupType := "acceptance"
        _bullConfType  := _accL_ct
    _bullConfStack := _bullConfStack == "" ? "acceptance" : _bullConfStack + ",acceptance"
if _rejL_d and _rejL_s >= minPatternScore
    if _rejL_s > _bullEngScore
        _bullEngScore  := _rejL_s
        _bullSetupType := "rejection"
        _bullConfType  := _rejL_ct
    _bullConfStack := _bullConfStack == "" ? "rejection" : _bullConfStack + ",rejection"

// Select best bear pattern
int    _bearEngScore  = 0
string _bearSetupType = "none"
string _bearConfType  = "none"
string _bearConfStack = ""

if enableBreakoutSetups and _brkS_d and _brkS_s >= minPatternScore
    if _brkS_s > _bearEngScore
        _bearEngScore  := _brkS_s
        _bearSetupType := "breakout"
        _bearConfType  := _brkS_ct
    _bearConfStack := _bearConfStack == "" ? "breakout" : _bearConfStack + ",breakout"
if enableContSetups and _ctS_d and _ctS_s >= minPatternScore
    if _ctS_s > _bearEngScore
        _bearEngScore  := _ctS_s
        _bearSetupType := "continuation"
        _bearConfType  := _ctS_ct
    _bearConfStack := _bearConfStack == "" ? "continuation" : _bearConfStack + ",continuation"
if enableRevSetups and _rvS_d and _rvS_s >= minPatternScore
    if _rvS_s > _bearEngScore
        _bearEngScore  := _rvS_s
        _bearSetupType := "reversal"
        _bearConfType  := _rvS_ct
    _bearConfStack := _bearConfStack == "" ? "reversal" : _bearConfStack + ",reversal"
if enableMRSetups and _mrS_d and _mrS_s >= minPatternScore
    if _mrS_s > _bearEngScore
        _bearEngScore  := _mrS_s
        _bearSetupType := "mean_reversion"
        _bearConfType  := _mrS_ct
    _bearConfStack := _bearConfStack == "" ? "mean_reversion" : _bearConfStack + ",mean_reversion"
if enableFBSetups and _fbS_d and _fbS_s >= minPatternScore
    if _fbS_s > _bearEngScore
        _bearEngScore  := _fbS_s
        _bearSetupType := "failed_breakout"
        _bearConfType  := _fbS_ct
    _bearConfStack := _bearConfStack == "" ? "failed_breakout" : _bearConfStack + ",failed_breakout"
if _swS_d and _swS_s >= minPatternScore
    if _swS_s > _bearEngScore
        _bearEngScore  := _swS_s
        _bearSetupType := "sweep_reclaim"
        _bearConfType  := _swS_ct
    _bearConfStack := _bearConfStack == "" ? "sweep" : _bearConfStack + ",sweep"
if _csdS_d and _csdS_s >= minPatternScore
    if _csdS_s > _bearEngScore
        _bearEngScore  := _csdS_s
        _bearSetupType := "csd"
        _bearConfType  := _csdS_ct
    _bearConfStack := _bearConfStack == "" ? "csd" : _bearConfStack + ",csd"
if _ifvgS_d and _ifvgS_s >= minPatternScore
    if _ifvgS_s > _bearEngScore
        _bearEngScore  := _ifvgS_s
        _bearSetupType := "ifvg"
        _bearConfType  := _ifvgS_ct
    _bearConfStack := _bearConfStack == "" ? "ifvg" : _bearConfStack + ",ifvg"
if _accS_d and _accS_s >= minPatternScore
    if _accS_s > _bearEngScore
        _bearEngScore  := _accS_s
        _bearSetupType := "acceptance"
        _bearConfType  := _accS_ct
    _bearConfStack := _bearConfStack == "" ? "acceptance" : _bearConfStack + ",acceptance"
if _rejS_d and _rejS_s >= minPatternScore
    if _rejS_s > _bearEngScore
        _bearEngScore  := _rejS_s
        _bearSetupType := "rejection"
        _bearConfType  := _rejS_ct
    _bearConfStack := _bearConfStack == "" ? "rejection" : _bearConfStack + ",rejection"

// High-confidence bonus: pattern score ≥7 adds +1 to letter grade
int _bullPatternBonus = _bullEngScore >= 7 ? 1 : 0
int _bearPatternBonus = _bearEngScore >= 7 ? 1 : 0

// ─── SCALP SIGNAL GATE ────────────────────────────────────────────────────────
// Layer 4: Entry & Risk Validation — all conditions must pass, any failure = no signal.

// ── Sweep flags (hoisted for reuse in stop calc, entry ext, and confirm count) ─
bool _didSweepBull = checkEarlySweepBull()
bool _didSweepBear = checkEarlySweepBear()

// ── Stop distance: structural, NOT ATR-based ──────────────────────────────────
// Reference = lowest low of prior 3 bars (long) / highest high (short).
float _stopRefLong  = math.min(low[1], math.min(low[2], low[3]))
float _stopRefShort = math.max(high[1], math.max(high[2], high[3]))
float _stopDistLong  = close - _stopRefLong
float _stopDistShort = _stopRefShort - close
bool  _stopOKLong    = _stopDistLong  > 0 and _stopDistLong  <= maxStopPoints
bool  _stopOKShort   = _stopDistShort > 0 and _stopDistShort <= maxStopPoints

// ── Entry extension: anti-chase filter ───────────────────────────────────────
// How far close has moved beyond the trigger level.
// Sweep reclaims reference the reclaimed VAL/VAH instead of prior bar high/low.
float _entryRefLong  = _didSweepBull and not na(_epDVAL) ? _epDVAL : high[1]
float _entryRefShort = _didSweepBear and not na(_epDVAH) ? _epDVAH : low[1]
float _entryExtLong  = math.max(0.0, close - _entryRefLong)
float _entryExtShort = math.max(0.0, _entryRefShort - close)
bool  _entryOKLong   = _entryExtLong  <= maxEntryExtPts
bool  _entryOKShort  = _entryExtShort <= maxEntryExtPts

// ── Risk/reward: nearest structural level as TP proxy ────────────────────────
array<float> _rrLvls = collectAllLvls()
float _tpLong  = na
float _tpShort = na
if array.size(_rrLvls) > 0
    for _i = 0 to array.size(_rrLvls) - 1
        float _lv = array.get(_rrLvls, _i)
        if _lv > close + syminfo.mintick
            if na(_tpLong)  or _lv < _tpLong
                _tpLong  := _lv
        if _lv < close - syminfo.mintick
            if na(_tpShort) or _lv > _tpShort
                _tpShort := _lv
float _rrLong  = not na(_tpLong)  and _stopDistLong  > 0 ? (_tpLong  - close) / _stopDistLong  : 0.0
float _rrShort = not na(_tpShort) and _stopDistShort > 0 ? (close - _tpShort) / _stopDistShort : 0.0
bool  _rrOKLong  = not enableRRFilter or (not na(_tpLong)  and _rrLong  >= minRR)
bool  _rrOKShort = not enableRRFilter or (not na(_tpShort) and _rrShort >= minRR)

// ── Confirmation count (reuses hoisted sweep flags) ──────────────────────────
int _bullConfirmCount = 0
if _didSweepBull and _swL_d
    _bullConfirmCount += 1
if _bullCommit
    _bullConfirmCount += 1
if _csdBullConf or _csdBullForm
    _bullConfirmCount += 1
if _ifvgL_d
    _bullConfirmCount += 1
if _accL_d
    _bullConfirmCount += 1
if _rejL_d
    _bullConfirmCount += 1
if _failedBearBreak
    _bullConfirmCount += 1

int _bearConfirmCount = 0
if _didSweepBear and _swS_d
    _bearConfirmCount += 1
if _bearCommit
    _bearConfirmCount += 1
if _csdBearConf or _csdBearForm
    _bearConfirmCount += 1
if _ifvgS_d
    _bearConfirmCount += 1
if _accS_d
    _bearConfirmCount += 1
if _rejS_d
    _bearConfirmCount += 1
if _failedBullBreak
    _bearConfirmCount += 1

// ── Scalp-weighted grade (20% bias + 30% loc + 30% confirm + 20% entry qual) ─
int _candBullGrade = _bullEngScore > 0 ? computeScalpGrade(_longBiasScore,  _bullConfirmCount, _stopDistLong)  : 0
int _candBearGrade = _bearEngScore > 0 ? computeScalpGrade(_shortBiasScore, _bearConfirmCount, _stopDistShort) : 0

// ── Counter-trend detection: setup against bias needs +1 confirmation ─────────
bool _counterTrendLong  = _shortBiasScore > _longBiasScore  + 1 and _shortBiasScore >= 4
bool _counterTrendShort = _longBiasScore  > _shortBiasScore + 1 and _longBiasScore  >= 4

// ── Required confirmations (grade-adjusted + counter-trend) ──────────────────
int _bullReqConf = math.max(minConfirmations, _candBullGrade >= 5 ? 3 : _candBullGrade >= 2 ? 2 : 1) + (_counterTrendLong  ? 1 : 0)
int _bearReqConf = math.max(minConfirmations, _candBearGrade >= 5 ? 3 : _candBearGrade >= 2 ? 2 : 1) + (_counterTrendShort ? 1 : 0)

// ── Setup scores (for minSetupScore gate) ─────────────────────────────────────
int _bullSetupScore = math.min(_bullEngScore * 10, 100)
int _bearSetupScore = math.min(_bearEngScore * 10, 100)

// ── Valid location ────────────────────────────────────────────────────────────
bool _nearVwap     = not na(dvwap) and math.abs(close - dvwap) <= atrVal * 0.7
bool _validBullLoc = prevAtLvl or _didSweepBull or _nearVwap or _belowDVAL or _farBelowPOC
bool _validBearLoc = prevAtLvl or _didSweepBear or _nearVwap or _aboveDVAH or _farAbovePOC

// ── Zone quality ──────────────────────────────────────────────────────────────
bool _zoneQualOK = not reqMedZoneQuality or prevLvlPriority() >= 1

// ── Middle-of-balance suppression ────────────────────────────────────────────
bool _inDValue   = not na(_epDVAH) and not na(_epDVAL) and close >= _epDVAL and close <= _epDVAH
float _bdyThresh = atrVal * 0.5
bool  _nearBound = (not na(_epDVAH) and math.abs(close - _epDVAH) <= _bdyThresh) or
                   (not na(_epDVAL) and math.abs(close - _epDVAL) <= _bdyThresh) or
                   (not na(_epDPOC) and math.abs(close - _epDPOC) <= _bdyThresh) or
                   prevAtLvl
bool  _midBalance = _inDValue and not _nearBound
bool  _midBlkBull = suppressMidBalance and _midBalance and _bullSetupType != "mean_reversion"
bool  _midBlkBear = suppressMidBalance and _midBalance and _bearSetupType != "mean_reversion"

// ── Cooldown ──────────────────────────────────────────────────────────────────
bool _bullCooldown = (bar_index - _bullCooldownBar) < signalCooldownBars
bool _bearCooldown = (bar_index - _bearCooldownBar) < signalCooldownBars

// ─── FINAL GATED SIGNALS ─────────────────────────────────────────────────────
bool rawBull = showTrigger
  and _bullSetupType != "none"
  and _bullSetupScore  >= minSetupScore
  and _bullConfirmCount >= _bullReqConf
  and (not requireValidLoc or _validBullLoc)
  and _zoneQualOK
  and not _midBlkBull
  and not _bullCooldown
  and _stopOKLong
  and _entryOKLong
  and _rrOKLong

bool rawBear = showTrigger
  and _bearSetupType != "none"
  and _bearSetupScore  >= minSetupScore
  and _bearConfirmCount >= _bearReqConf
  and (not requireValidLoc or _validBearLoc)
  and _zoneQualOK
  and not _midBlkBear
  and not _bearCooldown
  and _stopOKShort
  and _entryOKShort
  and _rrOKShort

bool goBull = rawBull and not _bullLatched
bool goBear = rawBear and not _bearLatched

if goBull
    _bullLatched     := true
    _bullCooldownBar := bar_index
if goBear
    _bearLatched     := true
    _bearCooldownBar := bar_index

int _bullGrade = goBull ? _candBullGrade : 0
int _bearGrade = goBear ? _candBearGrade : 0

// ─── OPTIONAL DEBUG TABLE (14 rows) ──────────────────────────────────────────
if showDebugTable and barstate.islast
    var table _dbg = table.new(position.bottom_right, 2, 14,
      bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50), border_width=1)
    string _blkB = _bullSetupType == "none"           ? "no_setup"
      : not _stopOKLong                               ? "stop_wide " + str.tostring(_stopDistLong,  "#.#") + "pts"
      : not _entryOKLong                              ? "entry_late " + str.tostring(_entryExtLong,  "#.#") + "pts"
      : not _rrOKLong                                 ? "rr_poor " + str.tostring(_rrLong,           "#.##") + "x"
      : requireValidLoc and not _validBullLoc         ? "no_location"
      : not _zoneQualOK                               ? "low_zone_quality"
      : _midBlkBull                                   ? "mid_balance"
      : _bullSetupScore  < minSetupScore              ? "score " + str.tostring(_bullSetupScore) + "<" + str.tostring(minSetupScore)
      : _bullConfirmCount < _bullReqConf              ? "confs " + str.tostring(_bullConfirmCount) + "<" + str.tostring(_bullReqConf)
      : _bullCooldown                                 ? "cooldown " + str.tostring(signalCooldownBars - (bar_index - _bullCooldownBar)) + "b"
      : _bullLatched                                  ? "latched"
      : "OK"
    string _blkS = _bearSetupType == "none"           ? "no_setup"
      : not _stopOKShort                              ? "stop_wide " + str.tostring(_stopDistShort, "#.#") + "pts"
      : not _entryOKShort                             ? "entry_late " + str.tostring(_entryExtShort, "#.#") + "pts"
      : not _rrOKShort                                ? "rr_poor " + str.tostring(_rrShort,          "#.##") + "x"
      : requireValidLoc and not _validBearLoc         ? "no_location"
      : not _zoneQualOK                               ? "low_zone_quality"
      : _midBlkBear                                   ? "mid_balance"
      : _bearSetupScore  < minSetupScore              ? "score " + str.tostring(_bearSetupScore) + "<" + str.tostring(minSetupScore)
      : _bearConfirmCount < _bearReqConf              ? "confs " + str.tostring(_bearConfirmCount) + "<" + str.tostring(_bearReqConf)
      : _bearCooldown                                 ? "cooldown " + str.tostring(signalCooldownBars - (bar_index - _bearCooldownBar)) + "b"
      : _bearLatched                                  ? "latched"
      : "OK"
    table.cell(_dbg, 0,  0, "DEBUG",          text_color=color.gray,   text_size=size.small)
    table.cell(_dbg, 1,  0, "BULL / BEAR",    text_color=color.gray,   text_size=size.small)
    table.cell(_dbg, 0,  1, "bias",           text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  1, _biasState + " (" + str.tostring(_longBiasScore) + "L/" + str.tostring(_shortBiasScore) + "S)", text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0,  2, "setup",          text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  2, _bullSetupType + " / " + _bearSetupType, text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0,  3, "score",          text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  3, str.tostring(_bullSetupScore) + " / " + str.tostring(_bearSetupScore), text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0,  4, "confirms",       text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  4, str.tostring(_bullConfirmCount) + "(req " + str.tostring(_bullReqConf) + ") / " + str.tostring(_bearConfirmCount) + "(req " + str.tostring(_bearReqConf) + ")", text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0,  5, "stop dist",      text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  5, str.tostring(_stopDistLong, "#.##") + "pts / " + str.tostring(_stopDistShort, "#.##") + "pts", text_color=(_stopOKLong or _stopOKShort) ? color.white : color.red, text_size=size.small)
    table.cell(_dbg, 0,  6, "entry ext",      text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  6, str.tostring(_entryExtLong, "#.##") + "pts / " + str.tostring(_entryExtShort, "#.##") + "pts", text_color=(_entryOKLong or _entryOKShort) ? color.white : color.red, text_size=size.small)
    table.cell(_dbg, 0,  7, "RR",             text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  7, str.tostring(_rrLong, "#.##") + "x / " + str.tostring(_rrShort, "#.##") + "x", text_color=(_rrOKLong or _rrOKShort) ? color.white : color.red, text_size=size.small)
    table.cell(_dbg, 0,  8, "valid loc",      text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  8, (requireValidLoc ? (_validBullLoc ? "✓" : "✗") : "off") + " / " + (requireValidLoc ? (_validBearLoc ? "✓" : "✗") : "off"), text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0,  9, "mid-bal",        text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1,  9, (_midBlkBull ? "BLOCKED" : "ok") + " / " + (_midBlkBear ? "BLOCKED" : "ok"), text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0, 10, "cooldown",       text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1, 10, (_bullCooldown ? str.tostring(signalCooldownBars - (bar_index - _bullCooldownBar)) + "b left" : "ready") + " / " + (_bearCooldown ? str.tostring(signalCooldownBars - (bar_index - _bearCooldownBar)) + "b left" : "ready"), text_color=color.white, text_size=size.small)
    table.cell(_dbg, 0, 11, "ctr-trend",      text_color=color.white,  text_size=size.small)
    table.cell(_dbg, 1, 11, (_counterTrendLong ? "LONG vs bias" : "no") + " / " + (_counterTrendShort ? "SHORT vs bias" : "no"), text_color=color.orange, text_size=size.small)
    table.cell(_dbg, 0, 12, "bull gate",      text_color=color.lime,   text_size=size.small)
    table.cell(_dbg, 1, 12, _blkB,            text_color=goBull ? color.lime : color.orange, text_size=size.small)
    table.cell(_dbg, 0, 13, "bear gate",      text_color=color.red,    text_size=size.small)
    table.cell(_dbg, 1, 13, _blkS,            text_color=goBear ? color.red  : color.orange, text_size=size.small)

// ─── EARLY SIGNAL DETECTION ───────────────────────────────────────────────────
// Fires on bar X-1 (the zone-interaction bar) when directional pressure is visible,
// one full bar before the confirmed engulf trigger fires on bar X.
// Latches are independent from the confirmed signal latches so both stages can
// fire at the same zone approach without interfering with each other.

var bool _earlyBullLatched = false
var bool _earlyBearLatched = false

// Reset using the same two-consecutive-bar-away-from-levels rule as confirmed
if not currAtLvl and not prevAtLvl
    _earlyBullLatched := false
    _earlyBearLatched := false

// Zone eligibility: HTF profiles only, or any level the indicator tracks
bool _earlyZoneOK = earlyReqHTFZone ? earlyAtHTFZone() : currAtLvl

// Body-direction fractions for current bar
float _earlyRng      = high - low
float _earlyBullFrac = _earlyRng > 0 ? (close - low)  / _earlyRng : 0.5
float _earlyBearFrac = _earlyRng > 0 ? (high - close) / _earlyRng : 0.5

// Core directional check: close in upper ≥40% of bar's range (bull) or lower ≥40% (bear).
// 40% instead of the confirmed signal's 50% (trigBodyPct) — looser threshold allows
// earlier detection while still filtering flat/doji/indecision bars.
bool _earlyBodyBull = _earlyBullFrac >= 0.40
bool _earlyBodyBear = _earlyBearFrac >= 0.40

// Optional filter gates — each disabled by default, togglable in settings
bool _sweepOKBull   = not earlyReqSweep    or checkEarlySweepBull()
bool _sweepOKBear   = not earlyReqSweep    or checkEarlySweepBear()
bool _reclaimOKBull = not earlyReqReclaim  or (_earlyBullFrac >= 0.50)
bool _reclaimOKBear = not earlyReqReclaim  or (_earlyBearFrac >= 0.50)
bool _displOKBull   = not earlyReqDisplace or (close > open and (close - open) >= atrVal * 0.25)
bool _displOKBear   = not earlyReqDisplace or (close < open and (open - close) >= atrVal * 0.25)

// Bias + CVD alignment scaled by sensitivity setting
bool _earlyBiasOKBull = earlySensitivity == "aggressive" ? true : earlySensitivity == "conservative" ? (_pvaScrG >= 1 and _inKill) : _pvaScrG >= 0
bool _earlyBiasOKBear = earlySensitivity == "aggressive" ? true : earlySensitivity == "conservative" ? (_pvaScrG <= -1 and _inKill) : _pvaScrG <= 0
bool _earlyCvdOKBull  = earlySensitivity == "aggressive" ? true : cvdDir >= 0
bool _earlyCvdOKBear  = earlySensitivity == "aggressive" ? true : cvdDir <= 0

// Grade computation — same formula as confirmed but uses current-bar level priority
int _earlyBullGrade = _earlyZoneOK ? computeEarlyGrade( 1) : 0
int _earlyBearGrade = _earlyZoneOK ? computeEarlyGrade(-1) : 0

// Final early signal booleans
// `not goBull/goBear` prevents a rare same-bar double-signal on a bar that
// simultaneously qualifies as both early AND confirmed.
bool earlyBull = earlyEnabled and _earlyZoneOK and _earlyBodyBull and _sweepOKBull and _reclaimOKBull and _displOKBull and _earlyBiasOKBull and _earlyCvdOKBull and earlyGradeMet(_earlyBullGrade) and not _earlyBullLatched and not goBull
bool earlyBear = earlyEnabled and _earlyZoneOK and _earlyBodyBear and _sweepOKBear and _reclaimOKBear and _displOKBear and _earlyBiasOKBear and _earlyCvdOKBear and earlyGradeMet(_earlyBearGrade) and not _earlyBearLatched and not goBear

if earlyBull
    _earlyBullLatched := true
if earlyBear
    _earlyBearLatched := true

// ─── WEBHOOK ALERT HELPERS ────────────────────────────────────────────────────
// Returns a human-readable label for the highest-priority HTF level touched
// by the prior bar. The strategy_interpreter on the server parses these strings
// via substring match ("PW POC" → pw_poc, "PD VAH" → pd_vah, etc.).
zoneTouchedLabel() =>
    string z = ""
    // Monthly (highest authority)
    if array.size(pMoList) > 0
        Profile cM = array.get(pMoList, array.size(pMoList) - 1)
        z := touchedAt(cM.poc, 1) ? "PM POC" : touchedAt(cM.vah, 1) ? "PM VAH" : touchedAt(cM.val, 1) ? "PM VAL" : z
    // Weekly
    if z == "" and array.size(pWkList) > 0
        Profile cW = array.get(pWkList, array.size(pWkList) - 1)
        z := touchedAt(cW.poc, 1) ? "PW POC" : touchedAt(cW.vah, 1) ? "PW VAH" : touchedAt(cW.val, 1) ? "PW VAL" : z
    // Daily
    if z == "" and array.size(pDList) > 0
        Profile cD = array.get(pDList, array.size(pDList) - 1)
        z := touchedAt(cD.poc, 1) ? "PD POC" : touchedAt(cD.vah, 1) ? "PD VAH" : touchedAt(cD.val, 1) ? "PD VAL" : z
    // VWAPs
    if z == "" and showDv and touchedAt(dvwap, 1)
        z := "VWAP D"
    if z == "" and showWv and touchedAt(wvwap, 1)
        z := "VWAP W"
    if z == "" and showNy and touchedAt(nvwap, 1)
        z := "VWAP NY"
    // Initial Balance
    if z == "" and ibUseAsLevel and showIB and _ibLive
        z := touchedAt(_ibHi, 1) ? "IB High" : touchedAt(_ibLo, 1) ? "IB Low" : z
    z == "" ? "level" : z

// Zone quality from the level priority at the prior bar
zoneQualityStr() =>
    int pri = prevLvlPriority()
    pri >= 3 ? "strong" : pri >= 2 ? "medium" : "weak"

// ─── JSON ALERTS → webhook → permission engine ────────────────────────────────
// Fires when goBull/goBear trigger. Payload is parsed by strategy_interpreter.js.
// TradingView alert condition: "Any alert() function call" + webhook URL.
if goBull
    string _az   = zoneTouchedLabel()
    float  _inv  = math.min(low[1], low) - syminfo.mintick * 2
    string _stk  = webhookIncludeStack ? ',"confirmation_stack":"' + _bullConfStack + '"' : ""
    string _psc  = str.tostring(math.min(_bullEngScore * 10, 100))
    string _lsc  = str.tostring(prevLvlPriority() * 25)
    alert('{"symbol":"' + syminfo.ticker
      + '","timeframe":"'           + timeframe.period
      + '","price":'                + str.tostring(close)
      + ',"event_type":"trigger"'
      + ',"trigger_status":"confirmed"'
      + ',"setup_stage":"confirmed"'
      + ',"setup_type":"'           + _bullSetupType + '"'
      + ',"direction":"long"'
      + ',"technical_bias":"bullish"'
      + ',"active_zone":"'          + _az + '"'
      + ',"zone_type":"support"'
      + ',"zone_quality":"'         + zoneQualityStr() + '"'
      + ',"grade":"'                + gradeLetter(_bullGrade) + '"'
      + ',"primary_confirmation":"' + _bullConfType + '"'
      + ',"pattern_score":'         + _psc
      + ',"location_score":'        + _lsc
      + _stk
      + ',"invalidation":'          + str.tostring(_inv)
      + ',"notes":"'                + _bullSetupType + ' long at ' + _az + ' (' + gradeLetter(_bullGrade) + ')"'
      + '}', alert.freq_once_per_bar)

if goBear
    string _az   = zoneTouchedLabel()
    float  _inv  = math.max(high[1], high) + syminfo.mintick * 2
    string _stk  = webhookIncludeStack ? ',"confirmation_stack":"' + _bearConfStack + '"' : ""
    string _psc  = str.tostring(math.min(_bearEngScore * 10, 100))
    string _lsc  = str.tostring(prevLvlPriority() * 25)
    alert('{"symbol":"' + syminfo.ticker
      + '","timeframe":"'           + timeframe.period
      + '","price":'                + str.tostring(close)
      + ',"event_type":"trigger"'
      + ',"trigger_status":"confirmed"'
      + ',"setup_stage":"confirmed"'
      + ',"setup_type":"'           + _bearSetupType + '"'
      + ',"direction":"short"'
      + ',"technical_bias":"bearish"'
      + ',"active_zone":"'          + _az + '"'
      + ',"zone_type":"resistance"'
      + ',"zone_quality":"'         + zoneQualityStr() + '"'
      + ',"grade":"'                + gradeLetter(_bearGrade) + '"'
      + ',"primary_confirmation":"' + _bearConfType + '"'
      + ',"pattern_score":'         + _psc
      + ',"location_score":'        + _lsc
      + _stk
      + ',"invalidation":'          + str.tostring(_inv)
      + ',"notes":"'                + _bearSetupType + ' short at ' + _az + ' (' + gradeLetter(_bearGrade) + ')"'
      + '}', alert.freq_once_per_bar)

// ─── EARLY SIGNAL ALERTS ──────────────────────────────────────────────────────
// Fires on the zone-interaction bar (one bar before confirmed). Payload has
// event_type:"event", trigger_status:"forming", setup_stage:"early" so the
// permission engine can route it separately from confirmed triggers.
if earlyBull and earlyAlertEn
    string _eaz = earlyZoneLabel()
    string _egt = gradeLetter(_earlyBullGrade)
    string _ect = checkEarlySweepBull() ? "sweep_reclaim_attempt" : _displOKBull ? "displacement_forming" : "rejection_attempt"
    float  _einv = low - syminfo.mintick * 2
    alert('{"symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"event_type":"event","trigger_status":"forming","setup_stage":"early","grade":"' + _egt + '","technical_bias":"bullish","active_zone":"' + _eaz + '","zone_type":"support","confirmation_type":"' + _ect + '","invalidation":' + str.tostring(_einv) + ',"notes":"Early long setup forming at ' + _eaz + ' (' + _egt + ')"}', alert.freq_once_per_bar)

if earlyBear and earlyAlertEn
    string _eaz = earlyZoneLabel()
    string _egt = gradeLetter(_earlyBearGrade)
    string _ect = checkEarlySweepBear() ? "sweep_reclaim_attempt" : _displOKBear ? "displacement_forming" : "rejection_attempt"
    float  _einv = high + syminfo.mintick * 2
    alert('{"symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"event_type":"event","trigger_status":"forming","setup_stage":"early","grade":"' + _egt + '","technical_bias":"bearish","active_zone":"' + _eaz + '","zone_type":"resistance","confirmation_type":"' + _ect + '","invalidation":' + str.tostring(_einv) + ',"notes":"Early short setup forming at ' + _eaz + ' (' + _egt + ')"}', alert.freq_once_per_bar)

// Ticket labels — rolling window of last 30 so chart doesn't get cluttered
var array<label> _tickets = array.new<label>()

if goBull and showTicket
    // Stop: the wider of structural (rejection bar low) and ATR-based
    float structStop = math.min(low[1], low)
    float atrStop    = close - atrStopMult * atrVal
    float stop       = math.min(structStop, atrStop) - syminfo.mintick * 2
    float stopDist   = close - stop
    // Targets
    float tp1 = na
    float tp2 = na
    if tpMode == "R multiples"
        tp1 := close + stopDist
        tp2 := close + stopDist * 2.0
    else
        array<float> allLvls = collectAllLvls()
        tp1 := nextLvlAbove(close, allLvls, 0)
        tp2 := nextLvlAbove(close, allLvls, 1)
        if na(tp1)
            tp1 := close + stopDist
        if na(tp2)
            tp2 := close + stopDist * 2.0
    // Size
    float dollarPerPt = syminfo.pointvalue
    float riskDollars = accountSize * riskPct / 100.0
    float contracts   = stopDist > 0 and dollarPerPt > 0 ? math.floor(riskDollars / (stopDist * dollarPerPt)) : 0.0
    string grdPrefix = showGrade ? gradeLetter(_bullGrade) + "  " : ""
    string stPrefix  = showSetupLabel and _bullSetupType != "none" ? "[" + _bullSetupType + "]\n" : ""
    string txt = stPrefix + grdPrefix + "LONG" + "\nE: "  + str.tostring(close, format.mintick) + "\nS: "  + str.tostring(stop, format.mintick) + "  (-" + str.tostring(stopDist, "#.##") + ")" + "\nT1: " + str.tostring(tp1, format.mintick) + " (+" + str.tostring(tp1 - close, "#.##") + ")" + "\nT2: " + str.tostring(tp2, format.mintick) + " (+" + str.tostring(tp2 - close, "#.##") + ")" + "\nSize: " + str.tostring(contracts, "#") + "c"
    label lb = label.new(bar_index, low - atrVal * 0.8, txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
    array.push(_tickets, lb)
    while array.size(_tickets) > 30
        label.delete(array.shift(_tickets))

if goBear and showTicket
    float structStop = math.max(high[1], high)
    float atrStop    = close + atrStopMult * atrVal
    float stop       = math.max(structStop, atrStop) + syminfo.mintick * 2
    float stopDist   = stop - close
    float tp1 = na
    float tp2 = na
    if tpMode == "R multiples"
        tp1 := close - stopDist
        tp2 := close - stopDist * 2.0
    else
        array<float> allLvls = collectAllLvls()
        tp1 := nextLvlBelow(close, allLvls, 0)
        tp2 := nextLvlBelow(close, allLvls, 1)
        if na(tp1)
            tp1 := close - stopDist
        if na(tp2)
            tp2 := close - stopDist * 2.0
    float dollarPerPt = syminfo.pointvalue
    float riskDollars = accountSize * riskPct / 100.0
    float contracts   = stopDist > 0 and dollarPerPt > 0 ? math.floor(riskDollars / (stopDist * dollarPerPt)) : 0.0
    string grdPrefix = showGrade ? gradeLetter(_bearGrade) + "  " : ""
    string stPrefix  = showSetupLabel and _bearSetupType != "none" ? "[" + _bearSetupType + "]\n" : ""
    string txt = stPrefix + grdPrefix + "SHORT" + "\nE: "  + str.tostring(close, format.mintick) + "\nS: "  + str.tostring(stop, format.mintick) + "  (+" + str.tostring(stopDist, "#.##") + ")" + "\nT1: " + str.tostring(tp1, format.mintick) + " (-" + str.tostring(close - tp1, "#.##") + ")" + "\nT2: " + str.tostring(tp2, format.mintick) + " (-" + str.tostring(close - tp2, "#.##") + ")" + "\nSize: " + str.tostring(contracts, "#") + "c"
    label lb = label.new(bar_index, high + atrVal * 0.8, txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
    array.push(_tickets, lb)
    while array.size(_tickets) > 30
        label.delete(array.shift(_tickets))

// ─── EARLY SIGNAL LABELS ──────────────────────────────────────────────────────
// Small "Early A / B / C" text at the bar, sitting closer to price than the
// confirmed ticket. Rolling window of 30 to stay within label budget.
var array<label> _earlyLabels = array.new<label>()

if earlyBull and showEarlyLabels
    color  _eLblCol = _earlyBullGrade >= 5 ? color.new(color.lime, 55) : _earlyBullGrade >= 2 ? color.new(color.aqua, 55) : color.new(color.gray, 65)
    label  _eLb = label.new(bar_index, low - atrVal * 0.4, "Early " + gradeLetter(_earlyBullGrade), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 85), textcolor=_eLblCol, style=label.style_none, size=size.tiny)
    array.push(_earlyLabels, _eLb)
    while array.size(_earlyLabels) > 30
        label.delete(array.shift(_earlyLabels))

if earlyBear and showEarlyLabels
    color  _eLblCol = _earlyBearGrade >= 5 ? color.new(color.red, 55) : _earlyBearGrade >= 2 ? color.new(color.orange, 55) : color.new(color.gray, 65)
    label  _eLb = label.new(bar_index, high + atrVal * 0.4, "Early " + gradeLetter(_earlyBearGrade), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 85), textcolor=_eLblCol, style=label.style_none, size=size.tiny)
    array.push(_earlyLabels, _eLb)
    while array.size(_earlyLabels) > 30
        label.delete(array.shift(_earlyLabels))

// Triangle color reflects grade when showGrade is on
color _bullTriColor = showGrade ? (_bullGrade >= 5 ? color.lime : _bullGrade >= 2 ? color.aqua    : color.new(color.gray, 20)) : color.lime
color _bearTriColor = showGrade ? (_bearGrade >= 5 ? color.red  : _bearGrade >= 2 ? color.orange  : color.new(color.gray, 20)) : color.red

// ── Confirmed signal shapes — triangles, unchanged ────────────────────────────
plotshape(goBull, title="Long Trigger",  style=shape.triangleup,   location=location.belowbar, color=_bullTriColor, size=size.small)
plotshape(goBear, title="Short Trigger", style=shape.triangledown, location=location.abovebar, color=_bearTriColor, size=size.small)

// ── Early signal shapes — circles, semi-transparent, size.tiny ───────────────
// Circle vs triangle makes early vs confirmed unmistakable at a glance.
color _earlyBullShapeCol = _earlyBullGrade >= 5 ? color.new(color.lime, 55) : _earlyBullGrade >= 2 ? color.new(color.aqua, 55) : color.new(color.gray, 60)
color _earlyBearShapeCol = _earlyBearGrade >= 5 ? color.new(color.red,  55) : _earlyBearGrade >= 2 ? color.new(color.orange, 55) : color.new(color.gray, 60)

plotshape(earlyEnabled and earlyBull, title="Early Long Setup",  style=shape.circle, location=location.belowbar, color=_earlyBullShapeCol, size=size.tiny)
plotshape(earlyEnabled and earlyBear, title="Early Short Setup", style=shape.circle, location=location.abovebar, color=_earlyBearShapeCol, size=size.tiny)

// ── Confirmed alertconditions — unchanged ─────────────────────────────────────
alertcondition(goBull, title="Long Trigger",  message="Long reversal trigger at level on {{ticker}} {{interval}}")
alertcondition(goBear, title="Short Trigger", message="Short reversal trigger at level on {{ticker}} {{interval}}")

// ── Early alertconditions — per-grade, long and short ─────────────────────────
alertcondition(earlyBull and _earlyBullGrade >= 5,                         title="Early Long — Grade A", message="Early A long setup forming on {{ticker}} {{interval}}")
alertcondition(earlyBull and _earlyBullGrade >= 2 and _earlyBullGrade < 5, title="Early Long — Grade B", message="Early B long setup forming on {{ticker}} {{interval}}")
alertcondition(earlyBull and _earlyBullGrade < 2,                          title="Early Long — Grade C", message="Early C long setup forming on {{ticker}} {{interval}}")
alertcondition(earlyBear and _earlyBearGrade >= 5,                         title="Early Short — Grade A", message="Early A short setup forming on {{ticker}} {{interval}}")
alertcondition(earlyBear and _earlyBearGrade >= 2 and _earlyBearGrade < 5, title="Early Short — Grade B", message="Early B short setup forming on {{ticker}} {{interval}}")
alertcondition(earlyBear and _earlyBearGrade < 2,                          title="Early Short — Grade C", message="Early C short setup forming on {{ticker}} {{interval}}")
````

# FF_WashLine

- url: https://www.tradingview.com/script/5xhkQO3I-FF-WashLine/
- type: indicator
- pine_id: PUB;47127e43948f4062bcf805fe3891f07f
- version: 1.0

## Description

FF WashLine tracks confirmed swing highs and lows and flags when one of those levels gets poked — pierced intrabar with a real rejection tail, but not closed through. The idea: retail breakout/stop orders cluster at obvious swing levels, so a quick spike through the level followed by a close back inside often marks liquidity being taken rather than a genuine breakout.

What it does

Detects confirmed swing highs/lows and adapts the pivot lookback to your chart’s timeframe (optional).
Identifies a “poke”: price pierces a tracked level by a minimum ATR-scaled depth, with a rejection tail large enough to rule out noise.
Spawns a wash line at the pierced level and tracks its life — departure from the level, retest touches, breaches, and failure/expiry.
Fires a trigger when a retested wash line gets a momentary stop pattern at the line (inside candle, outside candle in the trade’s direction, or a rejection tail), subject to a minimum score and a per-line cooldown.
Scores every active wash line 0–100 using a weighted blend of tail quality, level obviousness, cluster count, follow-through distance, retest count, and room to the next opposing swing level, then surfaces the nearest/strongest line’s values to the Data Window (score, direction, tier, level, stop reference, target, touches, room, age).
Draws entry/stop/target plan lines and a dashboard summarizing the active line’s state.

How to use it

Use the plotted wash lines and poke/trigger markers as a map of where recent “breakouts” were likely liquidity grabs rather than real continuation.
Watch FF_Score, FF_Tier, and the dashboard’s Bias/State/Score rows to gauge how strong the active setup is before considering a trade in that direction.
Long/short trigger markers show where a retest + momentary-stop pattern completed at a tracked line; the plotted plan lines show a sample entry/stop/target built from the configured min/max R targets.
All scoring weights, pivot lengths, ATR thresholds, and trigger conditions are exposed as inputs — this is meant to be tuned to the instrument and timeframe you trade, not used with one fixed setting.

Notes

All detection and signals are calculated from confirmed (closed) bars only — no repainting from intrabar pivot data.
The scoring weights are a starting framework, not a validated predictive model; past patterns are not a guarantee of future results.

## Source Code

````pine
//@version=6
// =============================================================================
// FF_WashLine  |  Fractal Flow suite  |  Market Maker Strategy module 1
// -----------------------------------------------------------------------------
// Course concept (Lectures 4, 15, 16, 20, 22): a wash line is the horizontal
// level of a swing high/low that was POKED (pierced) but NOT CLOSED beyond.
// Retail breakout orders cluster at that level; the spike is the manipulation,
// the line is where price tends to return, and the spike candle extreme is the
// built-in stop.
//
// What this module does
//   1. Tracks confirmed swing highs/lows (retail's "obvious" breakout levels).
//   2. Detects a poke: bar pierces a level, closes back inside, with a real
//      tail (Lecture 19: light pokes / tiny tails are market noise).
//   3. Spawns a wash line at the pierced level (highest pierced high / lowest
//      pierced low if several levels went at once) and tracks its life:
//      departure, retest touches, breaches, failure (stop), expiry.
//   4. Fires a trigger on a respected touch with a momentary stop: inside
//      candle, outside candle in trade direction, or a rejection tail.
//   5. Scores each line 0..100, signs it, and outputs the line nearest price
//      as FF_Score (+ bullish / - bearish) to the Data Window.
//
// Direction convention: +1 = bullish wash (lows poked, longs favoured)
//                       -1 = bearish wash (highs poked, shorts favoured)
//
// All detection runs on CONFIRMED bars only (course: wait for the candle to
// close). Score weights are UNVALIDATED until the harness has run them.
// Not in this version: sloped wash line (next module, seeds DynFreq), fractal
// candle trigger, multi-bar reclaim (close beyond, then close back).
// =============================================================================
indicator("FF_WashLine", shorttitle="FF WashLn", overlay=true, max_lines_count=500, max_labels_count=500)

// ---------------------------------------------------------------- INPUTS ----
const string GD = "Detection"
int    pvBase        = input.int(5, "Swing pivot length (bars @ reference TF)", minval=2, maxval=30, group=GD)
bool   adaptTf       = input.bool(true, "Adapt pivot length to chart timeframe", group=GD)
string refTf         = input.timeframe("5", "Reference timeframe", group=GD)
float  curveExp      = input.float(0.6, "TF scaling exponent", minval=0.1, maxval=1.5, step=0.05, group=GD)
int    pvFloor       = input.int(2, "Pivot length floor", minval=1, maxval=10, group=GD)
int    maxPiv        = input.int(40, "Max tracked swing levels per side", minval=5, maxval=100, group=GD)
int    maxLevelAge   = input.int(150, "Ignore swing levels older than (bars)", minval=20, maxval=450, group=GD, tooltip="Course rule: keep roughly 100-200 candles in view, independent of timeframe.")
int    atrLen        = input.int(14, "ATR length", minval=2, group=GD)
float  minPierceATR  = input.float(0.05, "Min pierce depth (x ATR)", minval=0.0, step=0.01, group=GD)
float  tailMin       = input.float(0.30, "Min spike tail ratio (tail / range)", minval=0.0, maxval=1.0, step=0.05, group=GD, tooltip="Below this the poke is treated as noise and the level is left alone.")
float  tailFull      = input.float(0.65, "Tail ratio for full tail score", minval=0.05, maxval=1.0, step=0.05, group=GD)

const string GW = "Wash line life"
float  touchTolATR   = input.float(0.15, "Touch tolerance (x ATR)", minval=0.0, step=0.01, group=GW)
float  minLeaveATR   = input.float(0.5, "Departure required before retests count (x ATR)", minval=0.0, step=0.1, group=GW)
float  departATR     = input.float(1.5, "Departure for full follow-through score (x ATR)", minval=0.1, step=0.1, group=GW)
int    maxAge        = input.int(150, "Wash line lifetime (bars)", minval=10, maxval=450, group=GW)
float  stopBufATR    = input.float(0.05, "Stop buffer beyond spike (x ATR)", minval=0.0, step=0.01, group=GW)
bool   failOnWick    = input.bool(false, "Fail on wick beyond stop (else on close)", group=GW)
int    breachMax     = input.int(3, "Closes beyond the line before it is dropped", minval=1, maxval=10, group=GW)
int    maxActive     = input.int(8, "Max active wash lines", minval=1, maxval=30, group=GW)

const string GT = "Trigger and plan"
bool   useInside     = input.bool(true, "Trigger: inside candle at the line", group=GT)
bool   useOutside    = input.bool(true, "Trigger: outside candle in trade direction after a touch", group=GT)
bool   useTail       = input.bool(true, "Trigger: rejection tail at the line", group=GT)
float  trigTailMin   = input.float(0.50, "Rejection tail ratio", minval=0.1, maxval=1.0, step=0.05, group=GT)
int    minTouchesTrig= input.int(1, "Min retest touches before a trigger", minval=1, maxval=6, group=GT)
float  trigMinScore  = input.float(35.0, "Min score to trigger", minval=0.0, maxval=100.0, group=GT)
int    trigCooldown  = input.int(5, "Trigger cooldown per line (bars)", minval=1, maxval=50, group=GT)
string entryMode     = input.string("Next open (close proxy)", "Entry reference", options=["Next open (close proxy)", "Limit at line"], group=GT)
float  minR          = input.float(3.0, "Target: min R multiple", minval=1.0, step=0.5, group=GT)
float  maxR          = input.float(4.0, "Target: max R multiple (snap window)", minval=1.0, step=0.5, group=GT)

const string GS = "Scoring (unvalidated)"
float  wTail         = input.float(25.0, "Weight: spike tail", minval=0.0, group=GS)
float  wObv          = input.float(20.0, "Weight: level obviousness", minval=0.0, group=GS)
float  wCluster      = input.float(10.0, "Weight: levels poked at once", minval=0.0, group=GS)
float  wDep          = input.float(20.0, "Weight: follow-through", minval=0.0, group=GS)
float  wTouch        = input.float(15.0, "Weight: retest touches", minval=0.0, group=GS)
float  wRoom         = input.float(10.0, "Weight: room to target", minval=0.0, group=GS)
float  freshFloor    = input.float(0.50, "Score multiplier at end of lifetime", minval=0.0, maxval=1.0, step=0.05, group=GS)
float  breachPen     = input.float(0.70, "Score multiplier per breach", minval=0.1, maxval=1.0, step=0.05, group=GS)
float  proxATR       = input.float(2.5, "Proximity window for FF_Score (x ATR)", minval=0.5, step=0.5, group=GS)
float  tierC         = input.float(35.0, "Tier C threshold", group=GS)
float  tierB         = input.float(55.0, "Tier B threshold", group=GS)
float  tierA         = input.float(75.0, "Tier A+ threshold", group=GS)

const string GV = "Display"
bool   showStop      = input.bool(true, "Show spike / stop reference line", group=GV)
bool   showLabels    = input.bool(true, "Show line labels", group=GV)
bool   showDead      = input.bool(true, "Keep failed / expired lines (dimmed)", group=GV)
bool   showPokeMarks = input.bool(true, "Show poke markers", group=GV)
bool   showTrigMarks = input.bool(true, "Show trigger markers", group=GV)
bool   showPlan      = input.bool(true, "Show entry / stop / target of last trigger", group=GV)
int    planBars      = input.int(12, "Plan line length (bars)", minval=3, maxval=100, group=GV)
int    lineW         = input.int(2, "Wash line width", minval=1, maxval=5, group=GV)
bool   showDash      = input.bool(true, "Show dashboard", group=GV)
string dashPosIn     = input.string("Top right", "Dashboard position", options=["Top left", "Top right", "Bottom left", "Bottom right"], group=GV)
color  colBear       = input.color(#ff1744, "Bearish wash (highs poked)", group=GV)
color  colBull       = input.color(#00c853, "Bullish wash (lows poked)", group=GV)
color  colStop       = input.color(#ff9100, "Spike / stop", group=GV)
color  colEntry      = input.color(#ffd600, "Plan entry", group=GV)
color  colTgt        = input.color(#2979ff, "Plan target", group=GV)
color  colHdr        = input.color(#c2185b, "Dashboard header", group=GV)

// ----------------------------------------------------------------- TYPES ----
type Pv
    float price
    int   bar
    int   touches = 0

type WL
    int    dir
    float  lvl
    float  spike
    int    originBar
    int    pokeBar
    float  atr0
    float  tail
    int    cluster
    float  obv
    int    touches      = 0
    int    breaches     = 0
    int    lastTouchBar = na
    int    lastTrigBar  = na
    float  depMax       = 0.0
    bool   departed     = false
    float  score        = 0.0
    float  roomR        = 0.0
    float  tgt          = na
    bool   snapped      = false
    line   ln
    line   sl
    label  lb

// ----------------------------------------------------------------- STATE ----
var array<Pv> pvH = array.new<Pv>()
var array<Pv> pvL = array.new<Pv>()
var array<WL> wls = array.new<WL>()

var float  sScore     = 0.0
var int    sDir       = 0
var int    sTier      = 0
var float  sLevel     = na
var float  sStop      = na
var float  sTgt       = na
var int    sTouches   = 0
var float  sRoom      = na
var float  sAge       = na
var string sStateTxt  = "no active wash line"
var int    lastTrigBarG = na
var int    lastTrigDirG = 0

var line   planEntry  = na
var line   planStop   = na
var line   planTgt    = na
var label  planLb     = na

// --------------------------------------------------------------- HELPERS ----
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_obv(Pv p, bool isNewest) =>
    int   age = bar_index - p.bar
    float tS  = f_clamp(p.touches / 3.0, 0.0, 1.0)
    float rS  = 1.0 - f_clamp(age / float(maxLevelAge), 0.0, 1.0)
    0.40 * tS + 0.35 * rS + 0.25 * (isNewest ? 1.0 : 0.0)

f_cap(array<Pv> a, int cap) =>
    while array.size(a) > cap
        array.shift(a)
    true

// Nearest opposing swing between minRR and maxRR (snap), plus farthest room.
f_target(array<Pv> arr, int dir, float entryPx, float risk, float minRR, float maxRR) =>
    float far   = 0.0
    float bestD = na
    float snap  = na
    int   n     = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            Pv p = array.get(arr, i)
            float d = dir == -1 ? entryPx - p.price : p.price - entryPx
            if d > far
                far := d
            if d >= minRR * risk and d <= maxRR * risk
                if na(bestD) or d < bestD
                    bestD := d
                    snap  := p.price
    [far, snap]

// Scan one side's tracked swings against the current bar.
// Removes broken / stale levels, counts touches, consumes poked levels.
f_scan(array<Pv> arr, bool isHigh, float atrNow, float tailRatio) =>
    int   cnt    = 0
    float lvl    = na
    int   origin = na
    float obv    = 0.0
    int   n      = array.size(arr)
    if n > 0
        int newest = 0
        for j = 0 to n - 1
            Pv q = array.get(arr, j)
            if q.bar > newest
                newest := q.bar
        float pMin = atrNow * minPierceATR
        float tl   = atrNow * touchTolATR
        for i = n - 1 to 0
            Pv p = array.get(arr, i)
            bool  old = bar_index - p.bar > maxLevelAge
            bool  brk = isHigh ? close > p.price : close < p.price
            float ext = isHigh ? high - p.price : p.price - low
            bool  rm  = false
            if old or brk
                rm := true
            else if ext > pMin and tailRatio >= tailMin
                cnt := cnt + 1
                bool better = na(lvl) or (isHigh ? p.price > lvl : p.price < lvl)
                if better
                    lvl    := p.price
                    origin := p.bar
                    obv    := f_obv(p, p.bar == newest)
                rm := true
            else if ext >= -tl
                p.touches := p.touches + 1
            if rm
                array.remove(arr, i)
            int loopDone = i
    [cnt, lvl, origin, obv]

f_wlScore(WL w) =>
    float stopPx = w.dir == -1 ? w.spike + w.atr0 * stopBufATR : w.spike - w.atr0 * stopBufATR
    float risk   = math.max(math.abs(w.lvl - stopPx), syminfo.mintick)
    array<Pv> opp = pvL
    if w.dir == 1
        opp := pvH
    [far, snap] = f_target(opp, w.dir, w.lvl, risk, minR, maxR)
    w.roomR   := far / risk
    w.tgt     := snap
    w.snapped := not na(snap)
    float tailS = f_clamp((w.tail - tailMin) / math.max(tailFull - tailMin, 0.0001), 0.0, 1.0)
    float obvS  = w.obv
    float clS   = w.cluster >= 3 ? 1.0 : w.cluster == 2 ? 0.7 : 0.4
    float depS  = f_clamp(w.depMax / math.max(departATR * w.atr0, syminfo.mintick), 0.0, 1.0)
    float tchS  = w.touches >= 2 ? 1.0 : w.touches == 1 ? 0.7 : 0.25
    float roomS = f_clamp(w.roomR / minR, 0.0, 1.0)
    float wsum  = math.max(wTail + wObv + wCluster + wDep + wTouch + wRoom, 0.0001)
    float raw   = (wTail * tailS + wObv * obvS + wCluster * clS + wDep * depS + wTouch * tchS + wRoom * roomS) / wsum * 100.0
    int   age   = bar_index - w.pokeBar
    float fresh = 1.0 - (1.0 - freshFloor) * f_clamp(age / float(maxAge), 0.0, 1.0)
    float brM   = math.pow(breachPen, w.breaches)
    raw * fresh * brM

f_newWL(int dir, float lvl, int origin, float obv, int cnt, float tailR, float atrNow) =>
    color c     = dir == -1 ? colBear : colBull
    float spike = dir == -1 ? high : low
    line ln = line.new(x1=origin, y1=lvl, x2=bar_index, y2=lvl, color=c, style=line.style_solid, width=lineW)
    line sl = na
    if showStop
        sl := line.new(x1=bar_index, y1=spike, x2=bar_index, y2=spike, color=colStop, style=line.style_dotted, width=1)
    label lb = na
    if showLabels
        lb := label.new(x=bar_index, y=lvl, text="", color=color.new(c, 100), style=label.style_label_left, textcolor=c, size=size.small)
    WL.new(dir=dir, lvl=lvl, spike=spike, originBar=origin, pokeBar=bar_index, atr0=atrNow, tail=tailR, cluster=cnt, obv=obv, ln=ln, sl=sl, lb=lb)

f_stateText(WL w) =>
    string s = "ARMED (no departure yet)"
    if w.departed
        s := "DEPARTED (awaiting retest)"
    if w.touches > 0
        s := "TESTED x" + str.tostring(w.touches)
    if w.breaches > 0
        s := s + " | breaches " + str.tostring(w.breaches)
    s

f_tierText(float mag) =>
    mag >= tierA ? "A+" : mag >= tierB ? "B" : mag >= tierC ? "C" : "-"

f_retire(WL w, string why) =>
    if showDead
        line.set_x2(w.ln, bar_index)
        line.set_color(w.ln, color.new(w.dir == -1 ? colBear : colBull, 80))
        line.set_style(w.ln, line.style_dashed)
        if not na(w.sl)
            line.set_x2(w.sl, bar_index)
            line.set_color(w.sl, color.new(colStop, 85))
        if not na(w.lb)
            label.set_x(w.lb, bar_index)
            label.set_text(w.lb, why)
            label.set_textcolor(w.lb, color.new(w.dir == -1 ? colBear : colBull, 55))
    else
        line.delete(w.ln)
        if not na(w.sl)
            line.delete(w.sl)
        if not na(w.lb)
            label.delete(w.lb)
    true

// ---------------------------------------------------------------- ENGINE ----
float adaptK = math.pow(timeframe.in_seconds(refTf) / timeframe.in_seconds(), curveExp)
int   pvLen  = adaptTf ? int(math.max(pvFloor, math.round(pvBase * adaptK))) : pvBase

float atrV = ta.atr(atrLen)
float phV  = ta.pivothigh(high, pvLen, pvLen)
float plV  = ta.pivotlow(low, pvLen, pvLen)

float barRng  = high - low
float upTail  = high - math.max(open, close)
float loTail  = math.min(open, close) - low
float upRatio = barRng > 0 ? upTail / barRng : 0.0
float loRatio = barRng > 0 ? loTail / barRng : 0.0
bool  insideC  = high <= high[1] and low >= low[1]
bool  outsideC = high > high[1] and low < low[1]

bool  pokeBullEvt = false
bool  pokeBearEvt = false
bool  trigLongEvt = false
bool  trigShortEvt = false
float trigEntry = na
float trigStopPx = na
float trigTgtPx = na
float trigRR = na
bool  trigSnap = false

if barstate.isconfirmed
    if not na(phV)
        array.push(pvH, Pv.new(price=phV, bar=bar_index - pvLen, touches=0))
        f_cap(pvH, maxPiv)
    if not na(plV)
        array.push(pvL, Pv.new(price=plV, bar=bar_index - pvLen, touches=0))
        f_cap(pvL, maxPiv)

    if not na(atrV)
        // ---- 1. detect pokes and spawn wash lines
        [hiCnt, hiLvl, hiOrg, hiObv] = f_scan(pvH, true, atrV, upRatio)
        [loCnt, loLvl, loOrg, loObv] = f_scan(pvL, false, atrV, loRatio)

        if hiCnt > 0
            if array.size(wls) >= maxActive
                f_retire(array.get(wls, 0), "dropped")
                array.shift(wls)
            array.push(wls, f_newWL(-1, hiLvl, hiOrg, hiObv, hiCnt, upRatio, atrV))
            pokeBearEvt := true
        if loCnt > 0
            if array.size(wls) >= maxActive
                f_retire(array.get(wls, 0), "dropped")
                array.shift(wls)
            array.push(wls, f_newWL(1, loLvl, loOrg, loObv, loCnt, loRatio, atrV))
            pokeBullEvt := true

        // ---- 2. update every live wash line
        WL    bestW     = na
        float bestEff   = -1.0
        float bestDistA = 1000000.0
        if array.size(wls) > 0
            for i = array.size(wls) - 1 to 0
                WL     w      = array.get(wls, i)
                bool   fresh0 = w.pokeBar == bar_index
                bool   dead   = false
                bool   touch  = false
                string why    = ""
                float  stopPx = w.dir == -1 ? w.spike + atrV * stopBufATR : w.spike - atrV * stopBufATR

                if not fresh0
                    bool beyondLvl = w.dir == -1 ? close > w.lvl : close < w.lvl
                    bool stopHit   = false
                    if failOnWick
                        stopHit := w.dir == -1 ? high > stopPx : low < stopPx
                    else
                        stopHit := w.dir == -1 ? close > stopPx : close < stopPx
                    if beyondLvl
                        w.breaches := w.breaches + 1
                    if stopHit
                        dead := true
                        why  := "x FAILED"
                    else if w.breaches >= breachMax
                        dead := true
                        why  := "x BROKEN"
                    else if bar_index - w.pokeBar > maxAge
                        dead := true
                        why  := "expired"
                    if not dead
                        float tolW  = atrV * touchTolATR
                        bool  reach = w.dir == -1 ? high >= w.lvl - tolW : low <= w.lvl + tolW
                        touch := w.departed and reach and not beyondLvl
                        if touch
                            w.touches      := w.touches + 1
                            w.lastTouchBar := bar_index
                        float exc = w.dir == -1 ? w.lvl - low : high - w.lvl
                        if exc > w.depMax
                            w.depMax := exc
                        if w.depMax >= minLeaveATR * w.atr0
                            w.departed := true

                if not dead
                    w.score := f_wlScore(w)

                    // ---- trigger: respected touch + momentary stop
                    if not fresh0
                        bool tailOk      = (w.dir == -1 ? upRatio : loRatio) >= trigTailMin
                        bool dirCandle   = w.dir == -1 ? close < open : close > open
                        bool touchRecent = touch or (w.lastTouchBar == bar_index - 1)
                        bool trigRaw     = (useInside and insideC and touch) or (useTail and tailOk and touch) or (useOutside and outsideC and dirCandle and touchRecent)
                        bool coolOK      = na(w.lastTrigBar) or bar_index - w.lastTrigBar >= trigCooldown
                        if trigRaw and coolOK and w.touches >= minTouchesTrig and w.score >= trigMinScore
                            float entryPx = entryMode == "Limit at line" ? w.lvl : close
                            float risk    = math.max(math.abs(entryPx - stopPx), syminfo.mintick)
                            array<Pv> opp2 = pvL
                            if w.dir == 1
                                opp2 := pvH
                            [far2, snap2] = f_target(opp2, w.dir, entryPx, risk, minR, maxR)
                            float tgtPx = na(snap2) ? (w.dir == -1 ? entryPx - minR * risk : entryPx + minR * risk) : snap2
                            w.lastTrigBar := bar_index
                            trigEntry  := entryPx
                            trigStopPx := stopPx
                            trigTgtPx  := tgtPx
                            trigRR     := math.abs(tgtPx - entryPx) / risk
                            trigSnap   := not na(snap2)
                            lastTrigBarG := bar_index
                            lastTrigDirG := w.dir
                            if w.dir == -1
                                trigShortEvt := true
                            else
                                trigLongEvt := true

                    // ---- proximity-weighted selection for the FF_Score read
                    float distA = math.abs(close - w.lvl) / math.max(atrV, syminfo.mintick)
                    float prox  = f_clamp(1.0 - distA / proxATR, 0.0, 1.0)
                    float eff   = w.score * prox
                    if na(bestW) or eff > bestEff or (eff == bestEff and distA < bestDistA)
                        bestEff   := eff
                        bestDistA := distA
                        bestW     := w

                    // ---- drawing upkeep
                    line.set_x2(w.ln, bar_index)
                    if not na(w.sl)
                        line.set_x2(w.sl, bar_index)
                    if not na(w.lb)
                        label.set_xy(w.lb, bar_index, w.lvl)
                        label.set_text(w.lb, (w.dir == -1 ? "▼ " : "▲ ") + str.tostring(w.touches) + "T " + f_tierText(w.score) + " " + str.tostring(math.round(w.score)))

                if dead
                    f_retire(w, why)
                    array.remove(wls, i)
                int loopDone = i

        // ---- 3. outputs (persist between confirmed bars)
        sScore    := 0.0
        sDir      := 0
        sTier     := 0
        sLevel    := na
        sStop     := na
        sTgt      := na
        sTouches  := 0
        sRoom     := na
        sAge      := na
        sStateTxt := "no active wash line"
        if not na(bestW)
            float e = math.max(bestEff, 0.0)
            sScore    := bestW.dir * e
            sDir      := bestW.dir
            sTier     := e >= tierA ? 3 : e >= tierB ? 2 : e >= tierC ? 1 : 0
            sLevel    := bestW.lvl
            sStop     := bestW.dir == -1 ? bestW.spike + atrV * stopBufATR : bestW.spike - atrV * stopBufATR
            sTgt      := bestW.tgt
            sTouches  := bestW.touches
            sRoom     := bestW.roomR
            sAge      := bar_index - bestW.pokeBar
            sStateTxt := f_stateText(bestW)

        // ---- 4. plan lines for the latest trigger
        if showPlan and (trigLongEvt or trigShortEvt)
            string planTxt = (trigLongEvt ? "LONG " : "SHORT ") + str.tostring(trigRR, "#.0") + "R" + (trigSnap ? " (anchored)" : "")
            if na(planEntry)
                planEntry := line.new(x1=bar_index, y1=trigEntry, x2=bar_index + planBars, y2=trigEntry, color=colEntry, style=line.style_dashed, width=1)
                planStop  := line.new(x1=bar_index, y1=trigStopPx, x2=bar_index + planBars, y2=trigStopPx, color=colStop, style=line.style_dashed, width=1)
                planTgt   := line.new(x1=bar_index, y1=trigTgtPx, x2=bar_index + planBars, y2=trigTgtPx, color=colTgt, style=line.style_dashed, width=1)
                planLb    := label.new(x=bar_index + planBars, y=trigTgtPx, text=planTxt, color=color.new(colTgt, 100), style=label.style_label_left, textcolor=colTgt, size=size.small)
            else
                line.set_xy1(planEntry, bar_index, trigEntry)
                line.set_xy2(planEntry, bar_index + planBars, trigEntry)
                line.set_xy1(planStop, bar_index, trigStopPx)
                line.set_xy2(planStop, bar_index + planBars, trigStopPx)
                line.set_xy1(planTgt, bar_index, trigTgtPx)
                line.set_xy2(planTgt, bar_index + planBars, trigTgtPx)
                label.set_xy(planLb, bar_index + planBars, trigTgtPx)
                label.set_text(planLb, planTxt)

int trigOut = trigLongEvt ? 1 : trigShortEvt ? -1 : 0
int pokeOut = pokeBullEvt ? 1 : pokeBearEvt ? -1 : 0

// ------------------------------------------------------- MARKERS / OUTPUTS ----
plotshape(showPokeMarks and pokeBearEvt, title="Bearish poke (highs washed)", style=shape.diamond, location=location.abovebar, color=colBear, size=size.tiny)
plotshape(showPokeMarks and pokeBullEvt, title="Bullish poke (lows washed)", style=shape.diamond, location=location.belowbar, color=colBull, size=size.tiny)
plotshape(showTrigMarks and trigShortEvt, title="Short trigger", style=shape.triangledown, location=location.abovebar, color=colBear, text="S", textcolor=colBear, size=size.small)
plotshape(showTrigMarks and trigLongEvt, title="Long trigger", style=shape.triangleup, location=location.belowbar, color=colBull, text="L", textcolor=colBull, size=size.small)

plot(sScore,   "FF_Score (+bull / -bear)", display=display.data_window)
plot(sTier,    "FF_Tier (0-/1 C/2 B/3 A+)", display=display.data_window)
plot(sDir,     "FF_WashDir", display=display.data_window)
plot(sLevel,   "FF_WashLevel", display=display.data_window)
plot(sStop,    "FF_WashStop", display=display.data_window)
plot(sTgt,     "FF_WashTarget (anchored only)", display=display.data_window)
plot(sTouches, "FF_WashTouches", display=display.data_window)
plot(sRoom,    "FF_WashRoomR", display=display.data_window)
plot(sAge,     "FF_WashAge", display=display.data_window)
plot(trigOut,  "FF_WashTrigger (+1 long / -1 short)", display=display.data_window)
plot(pokeOut,  "FF_WashPoke (+1 low washed / -1 high washed)", display=display.data_window)

alertcondition(trigLongEvt,  "FF WashLine: LONG trigger",  "FF_WashLine LONG trigger on {{ticker}} {{interval}}")
alertcondition(trigShortEvt, "FF WashLine: SHORT trigger", "FF_WashLine SHORT trigger on {{ticker}} {{interval}}")
alertcondition(pokeBullEvt,  "FF WashLine: lows washed (bullish wash line)", "FF_WashLine bullish poke on {{ticker}} {{interval}}")
alertcondition(pokeBearEvt,  "FF WashLine: highs washed (bearish wash line)", "FF_WashLine bearish poke on {{ticker}} {{interval}}")

// ------------------------------------------------------------- DASHBOARD ----
string dashPos = dashPosIn == "Top left" ? position.top_left : dashPosIn == "Top right" ? position.top_right : dashPosIn == "Bottom left" ? position.bottom_left : position.bottom_right
var table dash = table.new(dashPos, 2, 9, border_width=1, border_color=color.new(color.black, 40))

if barstate.islast and showDash
    color lblBg = #263238
    color valBg = sDir == -1 ? color.new(colBear, 55) : sDir == 1 ? color.new(colBull, 55) : #455a64
    float e     = math.abs(sScore)
    color tierBg = sTier == 3 ? #76ff03 : sTier == 2 ? #ffd600 : sTier == 1 ? #b0bec5 : #455a64
    color tierTx = sTier >= 1 ? color.black : color.white

    table.cell(dash, 0, 0, "FF WashLine", text_color=color.white, bgcolor=colHdr, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, str.tostring(array.size(wls)) + " active", text_color=color.white, bgcolor=colHdr, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 1, "Bias", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, sDir == -1 ? "SHORT ▼ (highs washed)" : sDir == 1 ? "LONG ▲ (lows washed)" : "none", text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 2, "State", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, sStateTxt, text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 3, "Wash line", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(sLevel) ? "-" : str.tostring(sLevel, format.mintick), text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 4, "Stop ref", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, na(sStop) ? "-" : str.tostring(sStop, format.mintick), text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 5, "Touches | age", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, na(sAge) ? "-" : str.tostring(sTouches) + " | " + str.tostring(sAge) + " bars", text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 6, "Score | tier", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(e)) + " | " + f_tierText(e), text_color=tierTx, bgcolor=tierBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 7, "Room | target", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, na(sRoom) ? "-" : str.tostring(sRoom, "#.0") + "R | " + (na(sTgt) ? "no anchor" : str.tostring(sTgt, format.mintick)), text_color=color.white, bgcolor=valBg, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 8, "Last trigger", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, na(lastTrigBarG) ? "-" : (lastTrigDirG == 1 ? "LONG " : "SHORT ") + str.tostring(bar_index - lastTrigBarG) + " bars ago", text_color=color.white, bgcolor=lblBg, text_size=size.small, text_halign=text.align_left)
````

# Liquidity Sweep Levels Pro

- url: https://www.tradingview.com/script/Y6gO4MHi-Liquidity-Sweep-Levels-Pro/
- type: indicator
- pine_id: PUB;b8de47367e4d45e3a89c95bb0c3585d0
- version: 2.0

## Description

LIQUIDITY SWEEP LEVELS PRO

WHAT IT DOES
Liquidity Sweep Levels Pro automatically detects buyside liquidity (BSL) and sellside liquidity (SSL) levels from confirmed swing pivots, draws them as horizontal lines that extend in real time, and identifies liquidity sweep events - moments where price wicks through a level to run resting stop orders and then closes back inside. It then applies a displacement-based confirmation model with confluence grading (A+/B/C) so you can distinguish genuine sweep reversals from continuation breaks.
The concept: swing highs accumulate buy stops and breakout orders above them (buyside liquidity); swing lows accumulate sell stops below them (sellside liquidity). When price pierces a level but fails to close beyond it, that liquidity has been consumed - a condition that frequently precedes a reversal toward the opposite pool. When price closes cleanly through a level instead, that is a break, and the indicator treats it as continuation rather than reversal.

HOW IT WORKS

Level detection: Swing highs and lows are identified using confirmed pivots (pivot length adapts to your chart timeframe in Auto mode, or can be set via Scalping / Intraday / Swing / Position / Manual modes). A pivot only becomes a level once fully confirmed - levels never appear retroactively.
Equal high/low clustering: New pivots forming within an ATR-based tolerance of an existing active level merge into it instead of stacking duplicate lines. Merged and retested levels grow thicker (up to 4x width), visually flagging multi-touch liquidity pools where the largest stop clusters accumulate.
Sweep vs break classification (mutually exclusive by construction):


SWEEP: wick pierces the level by at least the minimum pierce distance (ATR-based, configurable) but the bar closes back inside. Line turns dashed, sweep label prints.
BREAK: bar closes through the level. Continuation event, separate alert.


Displacement confirmation: A sweep alone does not confirm a reversal. After an SSL sweep, a later bar must close above the sweep bar's high within the confirmation window (default 5 bars) to print CONF LONG. Mirror logic for BSL sweeps and CONF SHORT. A close back through the sweep wick invalidates the setup; expiry cancels it silently.
Confluence grading: Each confirmed signal is graded using two optional filters measured on the sweep bar - EMA stack alignment (9/21/55) and relative volume (RVOL) - producing A+ (all confluences), B (partial), or C (none). A minimum-confluence gate can hard-filter signals if desired.

HOW TO USE IT

SSL SWEEP followed by CONF LONG: long setup. Stop below the sweep wick; first target is the nearest active BSL line above.
BSL SWEEP followed by CONF SHORT: short setup. Stop above the sweep wick; first target is the nearest active SSL line below.
Thicker lines mark multi-touch pools - sweeps of these levels are typically the higher-probability reversals.
The status table shows active level counts, nearest BSL/SSL prices, pending setup state with grade, and the last signal.
Six alerts are available: BSL/SSL Sweep, BSL/SSL Break, Confirmed Long, Confirmed Short.
Pine Screener support: persistent latched columns (sweep state, confirmed state, pending direction, confluence score, nearest levels, ATR distances) let you scan an entire watchlist for fresh sweep and confirmation events.

Suggested timeframes: 15m as the primary intraday chart; 5m for scalping in Scalping mode; 1H-Daily for swing context. On lower timeframes, raising Min Sweep Pierce (ATR) to 0.10-0.25 filters shallow wick grazes.

NON-REPAINTING DESIGN

All levels are created only from fully confirmed pivots, and all signals - sweeps, breaks, and confirmations - are evaluated strictly on confirmed bars. No signal, label, or line state changes retroactively. The inherent tradeoff of pivot-based detection is that a level appears only after its pivot confirms (pivot length bars after the actual swing); this is disclosed by design rather than hidden with lookahead.

SETTINGS OVERVIEW

Trading Mode: Auto (timeframe-adaptive) or fixed profiles / manual pivot length
Max Levels Per Side, ATR merge tolerance, retest tolerance
Min Sweep Pierce (ATR), swept/broken line handling
Confirmation Window, Min Confluence gate
EMA lengths, RVOL length and threshold, optional EMA plots
Full visual customization: labels, tags, colors, table position

LIMITATIONS AND NOTES

Levels require pivot confirmation, so the first bars of a session rely on levels carried from prior price action - prior-session highs and lows are typically the highest-quality pools.
Confirmation adds deliberate latency: the entry reference is the confirmation close, not the sweep close. This trades a later entry for a much lower false-positive rate.
This indicator identifies liquidity structure and event conditions. It is an analysis tool, not a trading system, and does not guarantee outcomes. Always apply your own risk management.

## Source Code

````pine
//@version=6
// Liquidity Sweep Levels Pro v1.1 - BSL/SSL liquidity lines with sweep detection, displacement confirmation, and EMA/RVOL confluence grading. v1.1: fixes the stale-grade ordering bug (confirmed score/grade captured before a same-bar new pending can overwrite them), eviction now removes dead (swept/broken) levels before active ones so relics cannot starve the watch-list, merge touch-bar stamped at the pivot bar, one sweep label per side per bar, table rewritten as a direction-neutral structure/triage panel (no long/short trade-call language), and display hygiene enforced (all inputs display.none, all pane plots display.pane). Alert titles and data-window plot titles unchanged for published-script continuity.
indicator(title = "Liquidity Sweep Levels Pro", shorttitle = "LIQ SWEEP PRO", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------------- Inputs ----------------
string GRP_MODE = "Mode"
string tradeMode = input.string("Auto", "Trading Mode", options = ["Auto", "Scalping", "Intraday", "Swing", "Position", "Manual"], group = GRP_MODE, display = display.none)
int manualPivotLen = input.int(10, "Manual Pivot Length", minval = 2, group = GRP_MODE, tooltip = "Used only when Trading Mode = Manual", display = display.none)

string GRP_LVL = "Levels"
int maxLevelsPerSide = input.int(8, "Max Levels Per Side", minval = 1, maxval = 25, group = GRP_LVL, display = display.none)
float mergeTolATR = input.float(0.25, "Equal High/Low Merge Tolerance (ATR)", minval = 0.0, step = 0.05, group = GRP_LVL, display = display.none)
float retestTolATR = input.float(0.15, "Retest Touch Tolerance (ATR)", minval = 0.0, step = 0.05, group = GRP_LVL, tooltip = "Bars that reject within this distance of a level thicken its line", display = display.none)
int atrLen = input.int(14, "ATR Length", minval = 1, group = GRP_LVL, display = display.none)

string GRP_SWEEP = "Sweep Logic"
float pierceMinATR = input.float(0.0, "Min Sweep Pierce (ATR)", minval = 0.0, step = 0.05, group = GRP_SWEEP, display = display.none)
bool keepSweptLines = input.bool(true, "Keep Swept Levels On Chart", group = GRP_SWEEP, display = display.none)
string brokenMode = input.string("Delete", "Broken Levels", options = ["Delete", "Keep Dotted"], group = GRP_SWEEP, display = display.none)
int holdBars = input.int(5, "Screener Signal Hold (bars)", minval = 1, maxval = 50, group = GRP_SWEEP, display = display.none)

string GRP_CONF = "Confirmation"
int confirmBars = input.int(5, "Confirmation Window (bars)", minval = 1, maxval = 20, group = GRP_CONF, tooltip = "Bars allowed after a sweep for a close through the sweep candle extreme", display = display.none)
int minConfl = input.int(0, "Min Confluence For Confirmed Signal", minval = 0, maxval = 2, group = GRP_CONF, tooltip = "0 = confirm on displacement alone, 1-2 = also require confluence score", display = display.none)

string GRP_CFL = "Confluence"
bool useEmaFilter = input.bool(true, "Use EMA Stack Confluence", group = GRP_CFL, display = display.none)
int emaFastLen = input.int(9, "EMA Fast", minval = 1, group = GRP_CFL, display = display.none)
int emaMidLen = input.int(21, "EMA Mid", minval = 1, group = GRP_CFL, display = display.none)
int emaSlowLen = input.int(55, "EMA Slow", minval = 1, group = GRP_CFL, display = display.none)
bool useRvol = input.bool(true, "Use RVOL Confluence", group = GRP_CFL, display = display.none)
int rvolLen = input.int(20, "RVOL Average Length", minval = 1, group = GRP_CFL, display = display.none)
float rvolThresh = input.float(1.2, "RVOL Threshold", minval = 0.5, step = 0.1, group = GRP_CFL, tooltip = "Session-blind SMA ratio. On extended-hours charts this over-fires near the regular open because premarket bars drag the average down. Treat as coarse confluence only.", display = display.none)
bool showEMAs = input.bool(false, "Plot Confluence EMAs", group = GRP_CFL, display = display.none)

string GRP_VIS = "Visuals"
bool showLevelTags = input.bool(false, "Show BSL/SSL Tags", group = GRP_VIS, display = display.none)
bool showSweepLabels = input.bool(true, "Show Sweep Labels", group = GRP_VIS, display = display.none)
bool showConfLabels = input.bool(true, "Show Confirmation Labels", group = GRP_VIS, display = display.none)
bool showTable = input.bool(true, "Show Status Table", group = GRP_VIS, display = display.none)
string tablePos = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_VIS, display = display.none)
color bslColor = input.color(color.rgb(239, 83, 80), "Buyside Liquidity", group = GRP_VIS, display = display.none)
color sslColor = input.color(color.rgb(38, 166, 154), "Sellside Liquidity", group = GRP_VIS, display = display.none)
color sweptColor = input.color(color.gray, "Swept Level", group = GRP_VIS, display = display.none)
color brokenColor = input.color(color.orange, "Broken Level", group = GRP_VIS, display = display.none)

// ---------------- Types ----------------
type LiqLevel
    float price
    int   createdBar
    int   touches
    int   lastTouchBar
    bool  isBuyside
    line  ln
    label lbl
    int   state // 0 = active, 1 = swept, 2 = broken

// ---------------- State ----------------
var array<LiqLevel> buyLevels = array.new<LiqLevel>()
var array<LiqLevel> sellLevels = array.new<LiqLevel>()

// ---------------- Helper Functions ----------------
getPivotLen(string mode, int manualLen) =>
    int result = manualLen
    if mode == "Auto"
        int tfSec = timeframe.in_seconds()
        if tfSec <= 300
            result := 5
        else if tfSec <= 3600
            result := 8
        else if tfSec <= 86400
            result := 10
        else
            result := 15
    else if mode == "Scalping"
        result := 5
    else if mode == "Intraday"
        result := 8
    else if mode == "Swing"
        result := 10
    else if mode == "Position"
        result := 15
    result

getTablePos(string p) =>
    string result = position.top_right
    if p == "Top Left"
        result := position.top_left
    else if p == "Bottom Right"
        result := position.bottom_right
    else if p == "Bottom Left"
        result := position.bottom_left
    result

gradeText(int score, int maxScore) =>
    string g = ""
    if maxScore <= 0
        g := ""
    else if score >= maxScore
        g := "A+"
    else if score > 0
        g := "B"
    else
        g := "C"
    g

// v1.1: merged pivots stamp the PIVOT bar as the touch bar, not the confirmation bar.
tryMergeLevel(array<LiqLevel> levels, float price, float tol, bool isBuyside, int pivLenIn) =>
    bool merged = false
    int i = 0
    while i < array.size(levels) and not merged
        LiqLevel lv = array.get(levels, i)
        if lv.state == 0 and math.abs(lv.price - price) <= tol
            lv.touches += 1
            lv.lastTouchBar := bar_index - pivLenIn
            float newPrice = isBuyside ? math.max(lv.price, price) : math.min(lv.price, price)
            lv.price := newPrice
            line.set_y1(lv.ln, newPrice)
            line.set_y2(lv.ln, newPrice)
            line.set_width(lv.ln, math.min(lv.touches, 4))
            if not na(lv.lbl)
                label.set_y(lv.lbl, newPrice)
            merged := true
        i += 1
    merged

// v1.1: pool eviction prefers DEAD levels (swept/broken relics) before active ones, oldest
// first in both passes, so kept-for-context lines can never starve the live watch-list.
addLevel(array<LiqLevel> levels, float price, bool isBuyside, int pivLenIn, color col, bool showTag, int maxLevels) =>
    line ln = line.new(bar_index - pivLenIn, price, bar_index, price, extend = extend.right, color = col, width = 1, style = line.style_solid)
    label lb = na
    if showTag
        string tagTxt = isBuyside ? "BSL" : "SSL"
        string tagStyle = isBuyside ? label.style_label_down : label.style_label_up
        lb := label.new(bar_index - pivLenIn, price, tagTxt, style = tagStyle, color = color.new(color.black, 100), textcolor = col, size = size.tiny)
    LiqLevel lv = LiqLevel.new(price, bar_index - pivLenIn, 1, bar_index - pivLenIn, isBuyside, ln, lb, 0)
    array.push(levels, lv)
    while array.size(levels) > maxLevels
        int rmIdx = 0
        int j = 0
        bool foundDead = false
        while j < array.size(levels) and not foundDead
            LiqLevel cand = array.get(levels, j)
            if cand.state != 0
                rmIdx := j
                foundDead := true
            j += 1
        LiqLevel old = array.get(levels, rmIdx)
        line.delete(old.ln)
        if not na(old.lbl)
            label.delete(old.lbl)
        array.remove(levels, rmIdx)
    lv

// v1.1: one sweep label per side per bar (multiple levels swept together previously
// stacked identical labels on top of each other).
processSide(array<LiqLevel> levels, bool isBuyside, float pierceTol, float retestTol, bool keepSwept, string brkMode, bool showLbls, color sideCol, color sweptCol, color brokenCol) =>
    bool sweptEvt = false
    bool brokenEvt = false
    float sweptPrice = na
    int i = 0
    while i < array.size(levels)
        LiqLevel lv = array.get(levels, i)
        bool removed = false
        if lv.state == 0
            bool sweepHit = false
            bool breakHit = false
            if isBuyside
                sweepHit := high > lv.price + pierceTol and close < lv.price
                breakHit := close > lv.price
            else
                sweepHit := low < lv.price - pierceTol and close > lv.price
                breakHit := close < lv.price
            if sweepHit
                if showLbls and not sweptEvt
                    string txt = isBuyside ? "BSL SWEEP" : "SSL SWEEP"
                    string lblStyle = isBuyside ? label.style_label_down : label.style_label_up
                    label.new(bar_index, lv.price, txt, style = lblStyle, color = color.new(sideCol, 15), textcolor = color.white, size = size.small)
                sweptEvt := true
                sweptPrice := lv.price
                if keepSwept
                    lv.state := 1
                    line.set_extend(lv.ln, extend.none)
                    line.set_x2(lv.ln, bar_index)
                    line.set_style(lv.ln, line.style_dashed)
                    line.set_color(lv.ln, sweptCol)
                    if not na(lv.lbl)
                        label.set_textcolor(lv.lbl, sweptCol)
                else
                    line.delete(lv.ln)
                    if not na(lv.lbl)
                        label.delete(lv.lbl)
                    array.remove(levels, i)
                    removed := true
            else if breakHit
                brokenEvt := true
                if brkMode == "Keep Dotted"
                    lv.state := 2
                    line.set_extend(lv.ln, extend.none)
                    line.set_x2(lv.ln, bar_index)
                    line.set_style(lv.ln, line.style_dotted)
                    line.set_color(lv.ln, brokenCol)
                    if not na(lv.lbl)
                        label.set_textcolor(lv.lbl, brokenCol)
                else
                    line.delete(lv.ln)
                    if not na(lv.lbl)
                        label.delete(lv.lbl)
                    array.remove(levels, i)
                    removed := true
            else
                bool retestHit = false
                if isBuyside
                    retestHit := high >= lv.price - retestTol and close < lv.price
                else
                    retestHit := low <= lv.price + retestTol and close > lv.price
                if retestHit and bar_index - lv.lastTouchBar >= 3
                    lv.touches += 1
                    lv.lastTouchBar := bar_index
                    line.set_width(lv.ln, math.min(lv.touches, 4))
        if not removed
            i += 1
    [sweptEvt, brokenEvt, sweptPrice]

countActive(array<LiqLevel> levels) =>
    int cnt = 0
    int i = 0
    while i < array.size(levels)
        LiqLevel lv = array.get(levels, i)
        if lv.state == 0
            cnt += 1
        i += 1
    cnt

nearestActive(array<LiqLevel> levels) =>
    float best = na
    float bestDist = na
    int i = 0
    while i < array.size(levels)
        LiqLevel lv = array.get(levels, i)
        if lv.state == 0
            float d = math.abs(close - lv.price)
            if na(bestDist) or d < bestDist
                bestDist := d
                best := lv.price
        i += 1
    best

// ---------------- Core Series (all unconditional, top-level) ----------------
int pivLen = getPivotLen(tradeMode, manualPivotLen)
float atrVal = ta.atr(atrLen)
float ph = ta.pivothigh(pivLen, pivLen)
float pl = ta.pivotlow(pivLen, pivLen)
float emaFastV = ta.ema(close, emaFastLen)
float emaMidV = ta.ema(close, emaMidLen)
float emaSlowV = ta.ema(close, emaSlowLen)
float volAvg = ta.sma(volume, rvolLen)

bool emaBull = emaFastV > emaMidV and emaMidV > emaSlowV
bool emaBear = emaFastV < emaMidV and emaMidV < emaSlowV
float rvolNow = not na(volAvg) and volAvg > 0 ? volume / volAvg : na
bool rvolOk = not na(rvolNow) and rvolNow >= rvolThresh

int maxScore = (useEmaFilter ? 1 : 0) + (useRvol ? 1 : 0)
int bullScore = (useEmaFilter and emaBull ? 1 : 0) + (useRvol and rvolOk ? 1 : 0)
int bearScore = (useEmaFilter and emaBear ? 1 : 0) + (useRvol and rvolOk ? 1 : 0)

// ---------------- Level Creation (confirmed bars only) ----------------
if barstate.isconfirmed
    float tol = nz(mergeTolATR * atrVal)
    if not na(ph)
        bool mergedHi = tryMergeLevel(buyLevels, ph, tol, true, pivLen)
        if not mergedHi
            addLevel(buyLevels, ph, true, pivLen, bslColor, showLevelTags, maxLevelsPerSide)
    if not na(pl)
        bool mergedLo = tryMergeLevel(sellLevels, pl, tol, false, pivLen)
        if not mergedLo
            addLevel(sellLevels, pl, false, pivLen, sslColor, showLevelTags, maxLevelsPerSide)

// ---------------- Sweep / Break Detection (confirmed bars only) ----------------
bool buySweepEvt = false
bool sellSweepEvt = false
bool buyBreakEvt = false
bool sellBreakEvt = false
float buySweptPrice = na
float sellSweptPrice = na

if barstate.isconfirmed
    float pierceTol = nz(pierceMinATR * atrVal)
    float retestTol = nz(retestTolATR * atrVal)
    [bs, bb, bp] = processSide(buyLevels, true, pierceTol, retestTol, keepSweptLines, brokenMode, showSweepLabels, bslColor, sweptColor, brokenColor)
    [ss, sb, sp] = processSide(sellLevels, false, pierceTol, retestTol, keepSweptLines, brokenMode, showSweepLabels, sslColor, sweptColor, brokenColor)
    buySweepEvt := bs
    buyBreakEvt := bb
    buySweptPrice := bp
    sellSweepEvt := ss
    sellBreakEvt := sb
    sellSweptPrice := sp

// ---------------- Pending Sweep Confirmation State Machine ----------------
// v1.1 FIX: the confirmed setup's score and grade are captured into confScoreEvt /
// confGradeEvt at resolution time, BEFORE step 2 can register a new pending from a
// same-bar sweep and overwrite pendScore/pendGrade. Previously the screener state and
// "Last Event" row reported the NEW pending's grade instead of the confirmed one,
// so the chart label and the table could disagree about the same event.
var int pendDir = 0
var float pendTrig = na
var float pendInval = na
var int pendBarIdx = 0
var int pendScore = 0
var string pendGrade = ""

bool confLongEvt = false
bool confShortEvt = false
int confScoreEvt = 0
string confGradeEvt = ""

if barstate.isconfirmed
    // 1) Resolve any pending setup using this bar (pending was set on an earlier bar)
    if pendDir == 1
        if bar_index - pendBarIdx > confirmBars
            pendDir := 0
        else if close < pendInval
            pendDir := 0
        else if close > pendTrig
            if pendScore >= minConfl
                confLongEvt := true
                confScoreEvt := pendScore
                confGradeEvt := pendGrade
                if showConfLabels
                    string txtL = "SSL RECLAIM"
                    if pendGrade != ""
                        txtL := txtL + " " + pendGrade
                    label.new(bar_index, low, txtL, style = label.style_label_up, color = color.new(color.teal, 0), textcolor = color.white, size = size.small)
            pendDir := 0
    else if pendDir == -1
        if bar_index - pendBarIdx > confirmBars
            pendDir := 0
        else if close > pendInval
            pendDir := 0
        else if close < pendTrig
            if pendScore >= minConfl
                confShortEvt := true
                confScoreEvt := pendScore
                confGradeEvt := pendGrade
                if showConfLabels
                    string txtS = "BSL REJECT"
                    if pendGrade != ""
                        txtS := txtS + " " + pendGrade
                    label.new(bar_index, high, txtS, style = label.style_label_down, color = color.new(color.maroon, 0), textcolor = color.white, size = size.small)
            pendDir := 0
    // 2) Register a new pending setup from this bar's sweep events (latest sweep governs)
    bool wantBull = sellSweepEvt
    bool wantBear = buySweepEvt
    if sellSweepEvt and buySweepEvt
        wantBull := close > open
        wantBear := not wantBull
    if wantBull
        pendDir := 1
        pendTrig := high
        pendInval := low
        pendBarIdx := bar_index
        pendScore := bullScore
        pendGrade := gradeText(bullScore, maxScore)
    else if wantBear
        pendDir := -1
        pendTrig := low
        pendInval := high
        pendBarIdx := bar_index
        pendScore := bearScore
        pendGrade := gradeText(bearScore, maxScore)

// ---------------- Screener Persistent States ----------------
var int sweepState = 0
var int sweepHold = 0
var int confState = 0
var int confHold = 0
var int lastConfScore = 0

if barstate.isconfirmed
    if buySweepEvt and sellSweepEvt
        sweepState := close > open ? 1 : -1
        sweepHold := holdBars
    else if buySweepEvt
        sweepState := -1
        sweepHold := holdBars
    else if sellSweepEvt
        sweepState := 1
        sweepHold := holdBars
    else if sweepHold > 0
        sweepHold -= 1
        if sweepHold == 0
            sweepState := 0
    if confLongEvt
        confState := 1
        confHold := holdBars
        lastConfScore := confScoreEvt
    else if confShortEvt
        confState := -1
        confHold := holdBars
        lastConfScore := confScoreEvt
    else if confHold > 0
        confHold -= 1
        if confHold == 0
            confState := 0

// ---------------- Metrics ----------------
int activeBSL = countActive(buyLevels)
int activeSSL = countActive(sellLevels)
float nearestBSL = nearestActive(buyLevels)
float nearestSSL = nearestActive(sellLevels)

float distBSLATR = na
float distSSLATR = na
if not na(nearestBSL) and not na(atrVal) and atrVal > 0.0
    distBSLATR := (nearestBSL - close) / atrVal
if not na(nearestSSL) and not na(atrVal) and atrVal > 0.0
    distSSLATR := (close - nearestSSL) / atrVal

// ---------------- EMA Plots (optional) ----------------
plot(showEMAs ? emaFastV : na, "EMA Fast", color = color.new(color.aqua, 30), linewidth = 1, display = display.pane)
plot(showEMAs ? emaMidV : na, "EMA Mid", color = color.new(color.orange, 30), linewidth = 1, display = display.pane)
plot(showEMAs ? emaSlowV : na, "EMA Slow", color = color.new(color.purple, 30), linewidth = 2, display = display.pane)

// ---------------- Pine Screener Outputs (titles unchanged for screener continuity) ----------------
plot(sweepState, "Sweep State (1 SSL / -1 BSL / 0 none)", display = display.data_window)
plot(confState, "Confirmed State (1 long / -1 short / 0 none)", display = display.data_window)
plot(pendDir, "Pending Dir (1 / -1 / 0)", display = display.data_window)
plot(lastConfScore, "Last Confirmed Confluence Score", display = display.data_window)
plot(activeBSL, "Active BSL Count", display = display.data_window)
plot(activeSSL, "Active SSL Count", display = display.data_window)
plot(nearestBSL, "Nearest BSL Price", display = display.data_window)
plot(nearestSSL, "Nearest SSL Price", display = display.data_window)
plot(distBSLATR, "Dist To BSL (ATR)", display = display.data_window)
plot(distSSLATR, "Dist To SSL (ATR)", display = display.data_window)
plot(buySweepEvt ? 1 : 0, "BSL Sweep Pulse", display = display.data_window)
plot(sellSweepEvt ? 1 : 0, "SSL Sweep Pulse", display = display.data_window)

// ---------------- Alerts (titles unchanged so existing user alerts keep working) ----------------
alertcondition(buySweepEvt, "BSL Sweep", "Buyside liquidity sweep - wick above swing high, close back below")
alertcondition(sellSweepEvt, "SSL Sweep", "Sellside liquidity sweep - wick below swing low, close back above")
alertcondition(buyBreakEvt, "BSL Break", "Close above buyside liquidity level")
alertcondition(sellBreakEvt, "SSL Break", "Close below sellside liquidity level")
alertcondition(confLongEvt, "Confirmed Long", "SSL sweep confirmed - close above sweep bar high within window")
alertcondition(confShortEvt, "Confirmed Short", "BSL sweep confirmed - close below sweep bar low within window")

// ---------------- Last Event Tracking (structure language, confirmed grade) ----------------
var string lastEvent = "—"
if barstate.isconfirmed
    if buyBreakEvt
        lastEvent := "BSL BROKEN"
    if sellBreakEvt
        lastEvent := "SSL BROKEN"
    if buySweepEvt
        lastEvent := "BSL SWEPT"
    if sellSweepEvt
        lastEvent := "SSL SWEPT"
    if confLongEvt
        lastEvent := "SSL RECLAIM" + (confGradeEvt != "" ? " " + confGradeEvt : "")
    if confShortEvt
        lastEvent := "BSL REJECT" + (confGradeEvt != "" ? " " + confGradeEvt : "")

// ---------------- Status Table: direction-neutral structure / triage panel ----------------
// v1.1: no trade-call language. The table reports market structure state only:
// liquidity inventory per side (count + nearest level + ATR distance), the live
// confluence readout, a neutral Watch row describing what PRICE must do to confirm
// the sweep structure, and the last structural event.
var table t = na
if showTable and barstate.islast
    if na(t)
        t := table.new(getTablePos(tablePos), 2, 7, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 60))
    string modeTxt = tradeMode + " (" + str.tostring(pivLen) + ")"
    string bslRow = str.tostring(activeBSL) + (na(nearestBSL) ? "" : " · " + str.tostring(nearestBSL, format.mintick) + " (" + str.tostring(distBSLATR, "#.#") + " ATR)")
    string sslRow = str.tostring(activeSSL) + (na(nearestSSL) ? "" : " · " + str.tostring(nearestSSL, format.mintick) + " (" + str.tostring(distSSLATR, "#.#") + " ATR)")
    string emaTxt = not useEmaFilter ? "off" : emaBull ? "stacked bull" : emaBear ? "stacked bear" : "mixed"
    string rvolTxt = not useRvol ? "off" : na(rvolNow) ? "—" : str.tostring(rvolNow, "#.##") + "x"
    string cflRow = "EMA " + emaTxt + " · RVOL " + rvolTxt
    string watchTxt = "—"
    if pendDir == 1
        watchTxt := "Reclaim > " + str.tostring(pendTrig, format.mintick) + (pendGrade != "" ? " (" + pendGrade + ")" : "")
    else if pendDir == -1
        watchTxt := "Breakdown < " + str.tostring(pendTrig, format.mintick) + (pendGrade != "" ? " (" + pendGrade + ")" : "")
    table.cell(t, 0, 0, "LIQ SWEEP PRO", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 0, modeTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 1, "BSL", text_color = bslColor, text_size = size.small)
    table.cell(t, 1, 1, bslRow, text_color = bslColor, text_size = size.small)
    table.cell(t, 0, 2, "SSL", text_color = sslColor, text_size = size.small)
    table.cell(t, 1, 2, sslRow, text_color = sslColor, text_size = size.small)
    table.cell(t, 0, 3, "Confluence", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 3, cflRow, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 4, "Watch", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 4, watchTxt, text_color = color.yellow, text_size = size.small)
    table.cell(t, 0, 5, "Sweep state", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 5, sweepState == 1 ? "SSL swept" : sweepState == -1 ? "BSL swept" : "—", text_color = color.yellow, text_size = size.small)
    table.cell(t, 0, 6, "Last event", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 6, lastEvent, text_color = color.yellow, text_size = size.small)
````

# Harmonic Pulse | XABCD Fibonacci Pattern Strategy

- url: https://www.tradingview.com/script/edChhkxo-Harmonic-Pulse-XABCD-Fibonacci-Pattern-Strategy/
- type: strategy
- pine_id: PUB;5350fd3629d4420dbc337beed247c85a
- version: 1.0

## Description

Harmonic Pulse scans zigzag swing pivots for the four classic Fibonacci harmonic patterns — Gartley, Bat, Butterfly, and Crab — and trades the reversal expected at the D-point completion. Rather than eyeballing X-A-B-C-D on the chart, it measures the AB/XA, BC/AB, CD/BC, and XD/XA leg ratios against each pattern's textbook Fibonacci targets and enters when enough of them line up, with a stop beyond the X point and a fixed reward:risk target.
[b]Features[/b]
[list]
[*]Pivot-based zigzag (adjustable Pivot Length) drives the whole pattern search
[*]Detects Gartley, Bat, Butterfly, and Crab — toggle any pattern on/off individually
[*]Partial-match scoring: choose how many of the 4 ratios must align (2–4) to fire a trade, instead of an all-or-nothing match
[*]Adjustable Ratio Tolerance to control how strictly price has to hit each Fibonacci level
[*]ATR-based stop beyond the X point, fixed Reward:Risk target
[*]Trade direction filter (Both / Long Only / Short Only) and cooldown between entries
[*]Every matched pattern is drawn on the chart (X-A-B-C-D lines) with its match score and key ratios labeled
[*]Plain zigzag pivot markers, independent of pattern matching, for a quick visual sanity check
[*]Live status readout: pivots stored, patterns found, open and closed trade counts
[/list]
[b]Tips[/b]
[list]
[*]Start on the Daily timeframe on liquid, volatile large caps (NVDA, TSLA, AMD, SPY) — harmonic trading is a swing-timeframe approach and needs room for real structure to form
[*]If nothing's triggering, watch the zigzag pivot markers first — if those aren't appearing, it's a chart/history issue, not a pattern-matching issue
[*]Treat Ratio Tolerance and Minimum Matching Ratios as a linked pair: loosen both together for more trades, tighten both together for higher-conviction ones
[*]Disable patterns you don't want to trade (e.g. turn off Crab if you only trust the tighter Gartley/Bat completions) rather than leaving all four on by default
[*]Backtest across multiple symbols and date ranges before trusting any single result — harmonic setups are infrequent, so one chart's backtest is a small sample
[/list]
[b]Warnings[/b]
[list]
[*]Pivot confirmation is inherently backward-looking — a pattern only confirms Pivot Length bars after the actual turn, so live behavior will lag what you see in a backtest
[*]Harmonic pattern trading is a discretionary, pattern-recognition approach without a rigorous statistical basis — treat this as a structured way to find candidate setups, not a proven edge
[*]Loosening Ratio Tolerance or lowering Minimum Matching Ratios increases trade frequency but degrades how closely price actually respects the pattern — more trades isn't automatically better
[*]Backtest results don't include realistic slippage on stops/gaps through targets; verify these assumptions before considering live use
[*]Not financial advice — this is a tool for research and idea generation, not a signal to act on directly
[*]
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Simple Harmonic Pattern Strategy — fundamentals only: zigzag pivots, four core
// XABCD Fibonacci patterns (Gartley, Bat, Butterfly, Crab), one stop, one target.
//@version=6
strategy("Simple Harmonic Pattern Strategy", shorttitle="Harmonic (Simple)", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.05, pyramiding=1)

// ───────────────────────────── Inputs ─────────────────────────────
zigLen = input.int(4, "Pivot Length", minval=2, maxval=30, group="Zigzag",
     tooltip="Bars required on each side to confirm a swing pivot. Lower = more, noisier pivots.")

useGartley   = input.bool(true, "Gartley",   group="Patterns", inline="p1")
useBat       = input.bool(true, "Bat",       group="Patterns", inline="p1")
useButterfly = input.bool(true, "Butterfly", group="Patterns", inline="p2")
useCrab      = input.bool(true, "Crab",      group="Patterns", inline="p2")
ratioTol       = input.float(0.10, "Ratio Tolerance", minval=0.02, maxval=0.3, step=0.01, group="Patterns")
minMatchRatios = input.int(3, "Minimum Matching Ratios (of 4)", minval=2, maxval=4, group="Patterns",
     tooltip="A pattern fires once this many of its 4 ratio checks pass, instead of needing all 4. Lower = looser, more frequent matches.")

tradeDirection = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"], group="Trade")
atrLen         = input.int(14, "ATR Length", minval=2, group="Trade")
stopAtrMult    = input.float(0.25, "Stop Buffer (x ATR beyond X)", minval=0, step=0.05, group="Trade")
targetRR       = input.float(2.0, "Target Reward:Risk", minval=0.5, step=0.1, group="Trade")
cooldownBars   = input.int(5, "Cooldown Bars After Entry", minval=0, group="Trade")

showPivots   = input.bool(true, "Show Zigzag Pivot Markers", group="Display")
showPatterns = input.bool(true, "Draw XABCD Patterns", group="Display")
bullColor    = input.color(color.new(#00c853, 0), "Bullish Color", group="Display")
bearColor    = input.color(color.new(#ff1744, 0), "Bearish Color", group="Display")

// ───────────────────────────── Zigzag ─────────────────────────────
var array<float> pvPrice = array.new<float>()
var array<int>   pvBar   = array.new<int>()
var array<int>   pvDir   = array.new<int>()   // 1 = pivot high, -1 = pivot low

f_pushPivot(float price, int bar, int dir) =>
    int cnt = array.size(pvDir)
    if cnt == 0
        array.push(pvPrice, price)
        array.push(pvBar, bar)
        array.push(pvDir, dir)
    else
        int lastDir = array.get(pvDir, cnt - 1)
        if dir == lastDir
            float lastPrice = array.get(pvPrice, cnt - 1)
            if (dir == 1 and price > lastPrice) or (dir == -1 and price < lastPrice)
                array.set(pvPrice, cnt - 1, price)
                array.set(pvBar, cnt - 1, bar)
        else
            array.push(pvPrice, price)
            array.push(pvBar, bar)
            array.push(pvDir, dir)
    while array.size(pvDir) > 20
        array.shift(pvPrice)
        array.shift(pvBar)
        array.shift(pvDir)

float pivHigh = ta.pivothigh(high, zigLen, zigLen)
float pivLow  = ta.pivotlow(low, zigLen, zigLen)
float atrVal  = ta.atr(atrLen)

if not na(pivHigh)
    f_pushPivot(pivHigh, bar_index - zigLen, 1)
if not na(pivLow)
    f_pushPivot(pivLow, bar_index - zigLen, -1)

bool newPivot = not na(pivHigh) or not na(pivLow)

// Plain pivot markers — independent of pattern matching, so you can confirm the
// zigzag itself is working even if no XABCD pattern ever completes.
plotshape(showPivots and not na(pivHigh), title="Pivot High", style=shape.triangledown,
     location=location.abovebar, offset=-zigLen, color=color.gray, size=size.tiny)
plotshape(showPivots and not na(pivLow), title="Pivot Low", style=shape.triangleup,
     location=location.belowbar, offset=-zigLen, color=color.gray, size=size.tiny)

// ───────────────────────────── Ratio checks ─────────────────────────────
f_in(float v, float lo, float hi) => v >= lo and v <= hi

f_gartleyScore(float ab, float bc, float cd, float xd) =>
    int s = 0
    s += f_in(ab, 0.618 - ratioTol, 0.618 + ratioTol) ? 1 : 0
    s += f_in(bc, 0.382 - ratioTol, 0.886 + ratioTol) ? 1 : 0
    s += f_in(cd, 1.13  - ratioTol, 1.618 + ratioTol) ? 1 : 0
    s += f_in(xd, 0.786 - ratioTol, 0.786 + ratioTol) ? 1 : 0
    s

f_batScore(float ab, float bc, float cd, float xd) =>
    int s = 0
    s += f_in(ab, 0.382 - ratioTol, 0.5   + ratioTol) ? 1 : 0
    s += f_in(bc, 0.382 - ratioTol, 0.886 + ratioTol) ? 1 : 0
    s += f_in(cd, 1.618 - ratioTol, 2.618 + ratioTol) ? 1 : 0
    s += f_in(xd, 0.886 - ratioTol, 0.886 + ratioTol) ? 1 : 0
    s

f_butterflyScore(float ab, float bc, float cd, float xd) =>
    int s = 0
    s += f_in(ab, 0.786 - ratioTol, 0.786 + ratioTol) ? 1 : 0
    s += f_in(bc, 0.382 - ratioTol, 0.886 + ratioTol) ? 1 : 0
    s += f_in(cd, 1.618 - ratioTol, 2.618 + ratioTol) ? 1 : 0
    s += f_in(xd, 1.27  - ratioTol, 1.618 + ratioTol) ? 1 : 0
    s

f_crabScore(float ab, float bc, float cd, float xd) =>
    int s = 0
    s += f_in(ab, 0.382 - ratioTol, 0.618 + ratioTol) ? 1 : 0
    s += f_in(bc, 0.382 - ratioTol, 0.886 + ratioTol) ? 1 : 0
    s += f_in(cd, 2.24  - ratioTol, 3.618 + ratioTol) ? 1 : 0
    s += f_in(xd, 1.618 - ratioTol, 1.618 + ratioTol) ? 1 : 0
    s

// ───────────────────────────── State ─────────────────────────────
var int   lastEntryBar  = na
var int   patternCount  = 0
var line  lXA = na
var line  lAB = na
var line  lBC = na
var line  lCD = na
var label lPat = na

f_clearLines() =>
    line.delete(lXA)
    line.delete(lAB)
    line.delete(lBC)
    line.delete(lCD)
    label.delete(lPat)

// ───────────────────────────── Detection + trade ─────────────────────────────
int cnt = array.size(pvDir)
bool haveFive = cnt >= 5

if haveFive and newPivot
    float Xp = array.get(pvPrice, cnt - 5)
    int   Xb = array.get(pvBar,   cnt - 5)
    float Ap = array.get(pvPrice, cnt - 4)
    int   Ab = array.get(pvBar,   cnt - 4)
    float Bp = array.get(pvPrice, cnt - 3)
    int   Bb = array.get(pvBar,   cnt - 3)
    float Cp = array.get(pvPrice, cnt - 2)
    int   Cb = array.get(pvBar,   cnt - 2)
    float Dp = array.get(pvPrice, cnt - 1)
    int   Db = array.get(pvBar,   cnt - 1)
    int   dDir = array.get(pvDir, cnt - 1)
    bool  isBullish = dDir == -1

    float XA = math.abs(Ap - Xp)
    float AB = math.abs(Bp - Ap)
    float BC = math.abs(Cp - Bp)
    float CD = math.abs(Dp - Cp)
    float XD = math.abs(Dp - Xp)

    if XA > 0 and AB > 0 and BC > 0
        float abR = AB / XA
        float bcR = BC / AB
        float cdR = CD / BC
        float xdR = XD / XA

        int gScore = useGartley   ? f_gartleyScore(abR, bcR, cdR, xdR)   : 0
        int bScore = useBat       ? f_batScore(abR, bcR, cdR, xdR)       : 0
        int fScore = useButterfly ? f_butterflyScore(abR, bcR, cdR, xdR) : 0
        int cScore = useCrab      ? f_crabScore(abR, bcR, cdR, xdR)      : 0
        int bestScore = math.max(math.max(gScore, bScore), math.max(fScore, cScore))
        bool matched  = bestScore >= minMatchRatios

        if matched
            string pname = gScore == bestScore ? "Gartley" : bScore == bestScore ? "Bat" : fScore == bestScore ? "Butterfly" : "Crab"
            patternCount += 1

            if showPatterns
                f_clearLines()
                color pcol = isBullish ? bullColor : bearColor
                lXA := line.new(Xb, Xp, Ab, Ap, color=pcol, width=2)
                lAB := line.new(Ab, Ap, Bb, Bp, color=pcol, width=2)
                lBC := line.new(Bb, Bp, Cb, Cp, color=pcol, width=2)
                lCD := line.new(Cb, Cp, Db, Dp, color=pcol, width=2)
                string txt = pname + " " + str.tostring(bestScore) + "/4" + (isBullish ? " Bull" : " Bear") + "\nAB " + str.tostring(abR, "#.###") + "  XD " + str.tostring(xdR, "#.###")
                lPat := label.new(Db, Dp, txt, style=isBullish ? label.style_label_up : label.style_label_down,
                     color=pcol, textcolor=color.white, size=size.small)

            bool longOk  = isBullish and tradeDirection != "Short Only"
            bool shortOk = (not isBullish) and tradeDirection != "Long Only"
            bool cooled  = na(lastEntryBar) or (bar_index - lastEntryBar) >= cooldownBars

            if cooled
                float stopPrice = isBullish ? Xp - stopAtrMult * atrVal : Xp + stopAtrMult * atrVal
                float risk      = math.abs(Dp - stopPrice)
                float target    = isBullish ? Dp + targetRR * risk : Dp - targetRR * risk

                if longOk
                    strategy.entry("Long", strategy.long, comment=pname)
                    strategy.exit("Long Exit", "Long", stop=stopPrice, limit=target)
                    lastEntryBar := bar_index
                if shortOk
                    strategy.entry("Short", strategy.short, comment=pname)
                    strategy.exit("Short Exit", "Short", stop=stopPrice, limit=target)
                    lastEntryBar := bar_index

// ───────────────────────────── Status label (sanity check) ─────────────────────────────
var label statusLbl = na
if barstate.islast
    label.delete(statusLbl)
    string stxt = "Pivots stored: " + str.tostring(cnt) + "\nPatterns found: " + str.tostring(patternCount) +
         "\nOpen trades: " + str.tostring(strategy.opentrades) + "\nClosed trades: " + str.tostring(strategy.closedtrades)
    statusLbl := label.new(bar_index, high, stxt, style=label.style_label_left,
         color=color.new(color.black, 20), textcolor=color.white, size=size.small)
````

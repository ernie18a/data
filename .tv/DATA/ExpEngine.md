<!-- tradingview-pine-id: PUB;9928ea18596640c798c1e48cff846bf5 -->
<!-- tradingviewscripts-format: 1 -->
# ExpEngine

Source: https://www.tradingview.com/script/Py8tmJA5-ExpEngine/

## Description

The engine behind the EXP GRID / EXP OVERLAY reconstruction pair.

An indicator is either overlay or pane, never both. So a study that wants to draw levels on price AND report statistics about those levels has to be two scripts — and two scripts means two copies of the decision logic, and two copies drift. This library exists so that they cannot: the pane cannot measure a different trade than the price chart draws, because there is only one definition of it.

WHAT IS IN HERE

context() — nine signed volume and efficiency features, each clamped to [-1, 1], and the composite they average into.
aligned() / plan() — the arming condition and the trade state machine: arm on alignment, enter on a break of the prior bar in the armed direction, exit on stop, target, or the clock, whichever comes first. Tracks MFE, MAE, realised R and a running win/loss record.
shadow() — a random-entry baseline that runs under the IDENTICAL exit rule. A base rate computed under a different exit rule is not a base rate.

TWO THINGS WORTH KNOWING

When both the stop and the target are touched inside a single bar, the intrabar path is unknowable, so plan() assumes the STOP filled first. Calling that one a win is the most common way a backtest lies to you.

macroBundle() applies [1] to every leg and is meant to be called with lookahead_on. That pairing is the only one of the four offset/lookahead combinations that reads a CLOSED higher-timeframe bar in both history and realtime; change one without the other and the script either leaks the future or disagrees with itself live. A library cannot make the request itself — Pine rejects a request.*() whose expression depends on an exported function's arguments (CE10051) — so the call site stays in your script:

[mEma, mAtr, mClose] = request.security(syminfo.tickerid, tf, es.macroBundle(len, aLen), lookahead = barmerge.lookahead_on)
float macroAtr = es.macroBias(mEma, mAtr, mClose)

Everything here reads confirmed bars only.

Library  "ExpEngine"

version()

macroBundle(len, aLen)
  Parameters:
    len (simple int)
    aLen (simple int)

macroBias(mEma, mAtr, mClose)
  Parameters:
    mEma (float)
    mAtr (float)
    mClose (float)

context(volLen, erFastLen, erSlowLen, atrLen, macroAtr)
  Parameters:
    volLen (simple int)
    erFastLen (simple int)
    erSlowLen (simple int)
    atrLen (simple int)
    macroAtr (float)

aligned(c, sessOpen, strongBand, armRvol)
  Parameters:
    c (Ctx)
    sessOpen (bool)
    strongBand (float)
    armRvol (float)

plan(c, ok, stopAtr, rr, timeExit)
  Parameters:
    c (Ctx)
    ok (bool)
    stopAtr (float)
    rr (float)
    timeExit (int)

shadow(c, sessOpen, every, stopAtr, rr, timeExit)
  Parameters:
    c (Ctx)
    sessOpen (bool)
    every (simple int)
    stopAtr (float)
    rr (float)
    timeExit (int)

Ctx
  Fields:
    fRvol (series float)
    fPress (series float)
    fCvd (series float)
    fVwma (series float)
    fEff (series float)
    fRange (series float)
    fClv (series float)
    fMacro (series float)
    fPersist (series float)
    composite (series float)
    macroAtr (series float)
    rvol (series float)
    atr (series float)
    erF (series float)
    erS (series float)
    hasVol (series bool)

Plan
  Fields:
    state (series int)
    dir (series int)
    entry (series float)
    stop (series float)
    target (series float)
    risk (series float)
    entryBar (series int)
    armed (series bool)
    entered (series bool)
    exited (series bool)
    win (series bool)
    rMult (series float)
    exitPx (series float)
    mfe (series float)
    mae (series float)
    mfeBar (series int)
    lastMfe (series float)
    lastMfeMin (series float)
    wins (series int)
    losses (series int)
    avgWinBars (series float)
    avgLossBars (series float)
    avgMaeWin (series float)
    sumR (series float)

Tally
  Fields:
    state (series int)
    dir (series int)
    entry (series float)
    stop (series float)
    target (series float)
    bar (series int)
    wins (series int)
    losses (series int)
    sumR (series float)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon

//@version=6
library("ExpEngine")

// ═══════════════════════════════════════════════════════════════════════════
//  The engine behind EXP GRID and EXP OVERLAY.
//
//  Both scripts used to carry a copy of this code with a comment asking the
//  author to keep them byte-identical, and a hand-typed version string that
//  was supposed to reveal it when they weren't. That check could only ever
//  detect a forgotten edit to the string, never a forgotten edit to the code.
//  It had already failed silently once.
//
//  With the engine here, the pane cannot measure a different trade than the
//  price chart draws — there is only one definition of it, and TradingView
//  enforces the version.
//
//  The exit rule in particular is defined once and used by both the signalled
//  trades and the random-entry baseline they are scored against. A base rate
//  computed under a different exit rule is not a base rate.
// ═══════════════════════════════════════════════════════════════════════════

// Printed by both scripts. One source, so the two can never disagree.
export version() =>
    "engine 2.0"

// ── Types ──────────────────────────────────────────────────────────────────

// The nine features and the state they are derived from. Signed, each clamped
// to [-1, 1], so the grid can colour them on one scale.
export type Ctx
    float fRvol    = 0.0
    float fPress   = 0.0
    float fCvd     = 0.0
    float fVwma    = 0.0
    float fEff     = 0.0
    float fRange   = 0.0
    float fClv     = 0.0
    float fMacro   = 0.0
    float fPersist = 0.0
    float composite = 0.0
    float macroAtr = na
    float rvol     = 1.0
    float atr      = na
    float erF      = 0.0
    float erS      = 0.0
    bool  hasVol   = false

// One trade, and the running record of every trade before it.
export type Plan
    int   state    = 0     // 0 flat, 1 armed, 2 live
    int   dir      = 0
    float entry    = na
    float stop     = na
    float target   = na
    float risk     = na
    int   entryBar = na
    bool  armed    = false // fired on the bar the setup armed
    bool  entered  = false // fired on the bar the trade opened
    bool  exited   = false // fired on the bar the trade closed
    bool  win      = false
    float rMult    = na    // realised R on the bar it exited
    float exitPx   = na
    float mfe      = na
    float mae      = na
    int   mfeBar   = na
    float lastMfe    = na
    float lastMfeMin = na
    int   wins     = 0
    int   losses   = 0
    float avgWinBars  = na
    float avgLossBars = na
    float avgMaeWin   = na
    float sumR     = 0.0   // total R banked, for expectancy

// Random-entry trades under the identical exit rule.
export type Tally
    int   state  = 0
    int   dir    = 0
    float entry  = na
    float stop   = na
    float target = na
    int   bar    = na
    int   wins   = 0
    int   losses = 0
    float sumR   = 0.0

// ── Helpers (not exported) ─────────────────────────────────────────────────
clamp(float x, float lo, float hi) =>
    na(x) ? na : math.max(lo, math.min(hi, x))

effRatio(simple int len) =>
    float net   = close - close[len]
    float gross = math.sum(math.abs(close - close[1]), len)
    gross == 0 or na(gross) ? 0.0 : net / gross

// ── Macro bias ─────────────────────────────────────────────────────────────
// A library cannot make the higher-timeframe request itself: Pine rejects a
// request.*() whose expression depends on an exported function's arguments
// (CE10051). So the call stays in each script and the two halves that are
// easy to get wrong live here instead.
//
// [1] on every leg, paired with lookahead_on at the call site: the only one
// of the four offset/lookahead combinations that reads a CLOSED higher-
// timeframe bar in both history and realtime. Change one without the other
// and the script either leaks the future or disagrees with itself live.
//
//     [mEma, mAtr, mClose] = request.security(syminfo.tickerid, tf,
//          es.macroBundle(len, aLen), lookahead = barmerge.lookahead_on)
//     float macroAtr = es.macroBias(mEma, mAtr, mClose)
export macroBundle(simple int len, simple int aLen) =>
    [ta.ema(close, len)[1], ta.atr(aLen)[1], close[1]]

export macroBias(float mEma, float mAtr, float mClose) =>
    na(mEma) or na(mAtr) ? na : (mClose - mEma) / math.max(mAtr, 1e-9)

// ── Features ───────────────────────────────────────────────────────────────
export context(simple int volLen, simple int erFastLen, simple int erSlowLen, simple int atrLen, float macroAtr) =>
    bool  hasVol = not na(volume) and volume > 0
    float avgVol = ta.sma(volume, volLen)
    float rvol   = na(avgVol) or avgVol == 0 ? 1.0 : volume / avgVol
    float atr    = ta.atr(atrLen)
    float dir    = math.sign(close - open)

    float fRvol  = clamp((rvol - 1.0) * dir, -1, 1)
    float fPress = clamp(ta.ema(volume * dir, volLen) / math.max(ta.ema(volume, volLen), 1e-9), -1, 1)

    float cvd     = ta.cum(volume * dir)
    float cvdNorm = ta.stdev(cvd - cvd[1], erSlowLen) * math.sqrt(erFastLen)
    float fCvd    = clamp((cvd - cvd[erFastLen]) / math.max(cvdNorm, 1e-9), -1, 1)

    float fVwma  = clamp((close - ta.vwma(close, volLen)) / math.max(atr, 1e-9), -1, 1)
    float erF    = effRatio(erFastLen)
    float erS    = effRatio(erSlowLen)
    float fEff   = clamp(erF, -1, 1)
    float fRange = clamp((ta.atr(erFastLen) / math.max(ta.atr(erSlowLen), 1e-9) - 1.0) * dir, -1, 1)

    float rng  = high - low
    float clv  = rng == 0 ? 0.0 : ((close - low) - (high - close)) / rng
    float fClv = clamp(ta.ema(clv * volume, volLen) / math.max(ta.ema(volume, volLen), 1e-9), -1, 1)

    float fMacro    = clamp(nz(macroAtr), -1, 1)
    float composite = clamp((fRvol + fPress + fCvd + fVwma + fEff + fRange + fClv + fMacro) / 8.0 * 2.0, -1, 1)
    float fPersist  = clamp(ta.sma(math.sign(composite), erSlowLen), -1, 1)

    Ctx.new(fRvol, fPress, fCvd, fVwma, fEff, fRange, fClv, fMacro, fPersist,
         composite, macroAtr, rvol, atr, erF, erS, hasVol)

// ── Arming condition ───────────────────────────────────────────────────────
export aligned(Ctx c, bool sessOpen, float strongBand, float armRvol) =>
    c.hasVol and sessOpen and math.abs(c.composite) >= strongBand and not na(c.macroAtr) and
         math.sign(c.composite) == math.sign(c.macroAtr) and c.rvol >= armRvol

// ── Signalled trades ───────────────────────────────────────────────────────
// Arms on alignment, enters on a break of the prior bar in the armed
// direction, exits on stop, target, or the clock — whichever comes first.
export plan(Ctx c, bool ok, float stopAtr, float rr, int timeExit) =>
    var Plan p = Plan.new()
    p.armed   := false
    p.entered := false
    p.exited  := false

    int wantDir = c.composite > 0 ? 1 : -1

    if barstate.isconfirmed
        if p.state == 0 and ok
            p.state := 1
            p.dir   := wantDir
            p.armed := true
        else if p.state == 1
            bool trigger = p.dir > 0 ? close > high[1] : close < low[1]
            if not ok
                p.state := 0
            else if trigger
                float risk = math.max(stopAtr * c.atr, syminfo.mintick)
                p.state    := 2
                p.entry    := close
                p.risk     := risk
                p.stop     := p.dir > 0 ? close - risk : close + risk
                p.target   := p.dir > 0 ? close + rr * risk : close - rr * risk
                p.entryBar := bar_index
                p.mfe      := 0.0
                p.mae      := 0.0
                p.mfeBar   := bar_index
                p.entered  := true
        else if p.state == 2
            float fav = p.dir > 0 ? high - p.entry : p.entry - low
            float adv = p.dir > 0 ? p.entry - low  : high - p.entry
            if fav > nz(p.mfe, 0)
                p.mfe    := fav
                p.mfeBar := bar_index
            if adv > nz(p.mae, 0)
                p.mae := adv
            bool hitStop = p.dir > 0 ? low  <= p.stop   : high >= p.stop
            bool hitTgt  = p.dir > 0 ? high >= p.target : low  <= p.target
            bool timeUp  = bar_index - p.entryBar >= timeExit
            if hitStop or hitTgt or timeUp
                // When both levels are touched inside one bar the intrabar
                // path is unknowable, so assume the STOP filled first.
                // Calling it a win is the most common way a backtest lies.
                bool  win      = hitTgt and not hitStop
                float exitPx   = hitStop ? p.stop : hitTgt ? p.target : close
                float heldBars = bar_index - p.entryBar
                float r        = (p.dir > 0 ? exitPx - p.entry : p.entry - exitPx) / math.max(p.risk, 1e-9)
                if win
                    p.wins += 1
                    p.avgWinBars := na(p.avgWinBars) ? heldBars : p.avgWinBars + (heldBars - p.avgWinBars) / p.wins
                    p.avgMaeWin  := na(p.avgMaeWin)  ? p.mae    : p.avgMaeWin  + (p.mae - p.avgMaeWin) / p.wins
                else
                    p.losses += 1
                    p.avgLossBars := na(p.avgLossBars) ? heldBars : p.avgLossBars + (heldBars - p.avgLossBars) / p.losses
                p.sumR       += r
                p.rMult      := r
                p.exitPx     := exitPx
                p.win        := win
                p.lastMfe    := p.mfe
                p.lastMfeMin := (p.mfeBar - p.entryBar) * timeframe.in_seconds() / 60.0
                p.exited     := true
                p.state      := 0
                p.entry      := na
                p.stop       := na
                p.target     := na
    p

// ── The base rate ──────────────────────────────────────────────────────────
// Same direction, same stop, same target, same clock, same exit rule — but
// entered at an arbitrary moment instead of a selected one. Whatever the
// signals beat, they have to beat THIS, not fifty percent.
export shadow(Ctx c, bool sessOpen, simple int every, float stopAtr, float rr, int timeExit) =>
    var Tally t = Tally.new()
    if barstate.isconfirmed and c.hasVol and sessOpen
        if t.state == 0
            if bar_index % every == 0 and not na(c.atr)
                float risk = math.max(stopAtr * c.atr, syminfo.mintick)
                t.state  := 1
                t.dir    := c.composite > 0 ? 1 : -1
                t.entry  := close
                t.stop   := t.dir > 0 ? close - risk : close + risk
                t.target := t.dir > 0 ? close + rr * risk : close - rr * risk
                t.bar    := bar_index
        else
            bool sStop = t.dir > 0 ? low  <= t.stop   : high >= t.stop
            bool sTgt  = t.dir > 0 ? high >= t.target : low  <= t.target
            bool sTime = bar_index - t.bar >= timeExit
            if sStop or sTgt or sTime
                bool  win    = sTgt and not sStop
                float exitPx = sStop ? t.stop : sTgt ? t.target : close
                float risk   = math.abs(t.entry - t.stop)
                t.sumR += (t.dir > 0 ? exitPx - t.entry : t.entry - exitPx) / math.max(risk, 1e-9)
                if win
                    t.wins += 1
                else
                    t.losses += 1
                t.state := 0
    t
````

# KILLER Lite. Trend Stack

- url: https://www.tradingview.com/script/HOwRxSbR-KILLER-Lite-Trend-Stack/
- type: indicator
- pine_id: PUB;9ec37f6a74c84dc48aa9168acee87eec
- version: 2.0

## Description

KILLER Lite · Trend Stack

WHAT IT IS
KILLER Lite is a trend-following indicator built around three independent trend "sleeves": FAST, MID and SLOW. Each sleeve decides its own direction, opens its own simulated trade and manages its own stop. The STACK (−3 to +3) counts how many sleeves are long minus how many are short, so you see at a glance how strongly the trend is agreed across horizons.

HOW IT WORKS
1) Consensus line. Each sleeve averages eight moving averages of the same length (EMA, SMA, WMA, HMA, RMA, DEMA, TEMA, ALMA). Using eight instead of one makes the line less dependent on any single smoothing method.
2) Flip with a band. A sleeve turns up only when the close is above its consensus line by 0.5 × ATR, and turns down only when the close is below it by 0.5 × ATR. Inside the band the previous direction is kept. This filters most of the back-and-forth flips in sideways markets.
3) Lengths in days. The sleeve lengths are set in days (default 8 / 17 / 25) and converted to bars for the chart timeframe: 48/102/150 bars on 4H, 24/51/75 on 8H, 8/17/25 on 1D.
4) Entries. Long on an up-flip. Short on a down-flip only when price is below the 200 EMA (the "gate"), so shorts are taken only in a broader downtrend.
5) Exits. Initial stop at 2 × ATR. Chandelier trail: 30-bar extreme minus (or plus) 5 × ATR, which only ever tightens. Exit on an opposite flip. Shorts also have a 5R profit target.
6) Pyramid. One add per trade when price breaks the last confirmed swing high (long) or swing low (short) in the trend direction.

WHAT YOU SEE
• Three consensus lines coloured by direction, with a ribbon between fast and slow coloured by the stack
• Triangles for sleeve entries (small / medium / large = fast / mid / slow), crosses for pyramid adds
• "KILLER ×3" label and a soft background glow when all three sleeves align
• Stop line for every open sleeve
• R label on each closed trade (result in units of initial risk)
• Dashboard: direction, position, stop and open R per sleeve, stack, short-gate state, simulated statistics, KILLER score (0–100, a rescaled stack), and a timeframe check
• Colour themes: Custom, Neon, Ocean, Mono

ALERTS
• Ready-made conditions: full stack long / short, sleeve long / short entry, pyramid add, stop or target hit, sleeve exit on trend flip
• "Any alert() function call" sends one message per bar close listing every event on that bar: ENTRY, ADD, EXIT, STOP_UPDATE, STOP_HIT

HOW TO USE IT
• Use it on 4H, 8H or 1D. The dashboard warns you outside that range.
• Read the stack first: +2 / +3 is a bullish trend, −2 / −3 bearish, around 0 is mixed.
• Each sleeve is a separate position with its own stop. You can follow all three, or only the slower ones for fewer trades.
• If you trade it live, keep the stop as a real order at your exchange and move it on every STOP_UPDATE. Alerts fire at bar close, so a stop touched inside a bar is reported only when that bar closes.

NOTES AND LIMITS
• Signals are calculated on closed bars only. No lookahead, no repainting of past signals.
• Entries are assumed at the next bar's open.
• The dashboard statistics come from a simple internal simulation on the chart's own history, with a configurable cost per side (default 0.06%). They ignore funding, slippage and position sizing, and they are not a backtest report.
• Trend following loses in sideways markets: expect many small losses and a few large wins.
• Developed and tested mainly on liquid crypto pairs. Behaviour on other markets is not validated.

This script is for information and education only. It is not financial advice. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/  —  © 2026 Boris Tatchou
// ═══════════════════════════════════════════════════════════════════════════════
//  KILLER Lite · Trend Stack
//
//  Three independent trend sleeves — FAST / MID / SLOW — each an 8-MA consensus line with an
//  ATR hysteresis flip. Lengths are set in DAYS (default 8 / 17 / 25), so the engine adapts
//  to any timeframe automatically. Each sleeve trades on its own:
//   • long on an up-flip; short on a down-flip only below the gate EMA (200)
//   • initial stop 2×ATR · chandelier trail (30-bar extreme − 5×ATR) · exit on opposite flip
//   • 5R profit target on shorts (crypto sell-offs snap back)
//   • one pyramid add per trade on a structure break (BOS) in the trend direction
//  The STACK (−3 … +3) is how many sleeves are long minus short — the net conviction.
//
//  Research: the v2 trend-stack engine, tuned 2018-2023 and validated 2024-2026; later exams on unseen coins
//  confirmed the same engine inside KILLER Pro.
//  Validated on 4H / 8H / 1D. Signals on bar close — non-repainting, no lookahead.
//  Alerts fire at BAR CLOSE: a stop hit inside a bar is reported at that bar's close. For live trading, keep a
//  stop order at the exchange and move it on every STOP_UPDATE event.
//  Not financial advice. Past performance does not guarantee future results.
// ═══════════════════════════════════════════════════════════════════════════════
indicator("KILLER Lite · Trend Stack", "KILLER Lite", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─── Inputs ────────────────────────────────────────────────────────────────────
grpE   = "Engine"
dFast  = input.float(8.0,  "Fast sleeve (days)", minval = 0.5, step = 0.5, group = grpE)
dMid   = input.float(17.0, "Mid sleeve (days)",  minval = 0.5, step = 0.5, group = grpE)
dSlow  = input.float(25.0, "Slow sleeve (days)", minval = 0.5, step = 0.5, group = grpE,
     tooltip = "Sleeve lengths in calendar days, converted to bars for the chart timeframe (4H: 48/102/150 bars, 8H: 24/51/75, 1D: 8/17/25).")
bandM  = input.float(0.5, "Flip band (× ATR)", minval = 0.0, step = 0.05, group = grpE)
atrLen = input.int(14, "ATR length", minval = 1, group = grpE)

grpS       = "Signals"
allowShort = input.bool(true, "Allow shorts", group = grpS)
gateShort  = input.bool(true, "Shorts only below gate EMA", group = grpS)
gateLen    = input.int(200, "Gate EMA length", minval = 1, group = grpS)
usePyr     = input.bool(true, "Pyramid: add 1 unit on BOS", group = grpS)
swingLen   = input.int(5, "BOS swing length", minval = 1, group = grpS)

grpR    = "Risk"
slMult  = input.float(2.0, "Initial stop (× ATR)", minval = 0.1, step = 0.1, group = grpR)
trLen   = input.int(30, "Trail lookback (bars)", minval = 1, group = grpR)
trMult  = input.float(5.0, "Trail distance (× ATR)", minval = 0.1, step = 0.1, group = grpR)
tpShort = input.float(5.0, "Short target (R, 0 = off)", minval = 0.0, step = 0.5, group = grpR)

grpV      = "Visuals"
showLines = input.bool(true, "Sleeve lines", group = grpV)
showRib   = input.bool(true, "Stack ribbon (fast ↔ slow)", group = grpV)
showGate  = input.bool(true, "Gate EMA", group = grpV)
showStops = input.bool(false, "Sleeve stop lines", group = grpV)
showFlips = input.bool(true, "Sleeve flip markers", group = grpV)
showAdds  = input.bool(true, "Pyramid add markers", group = grpV)
showStack = input.bool(true, "Full-stack labels (all 3 aligned)", group = grpV)
altStack  = input.bool(false, "Markers and labels: only on a change of direction", group = grpV,
     tooltip = "On: each marker type alternates. After a long entry marker the next entry marker shown is a short one, and the reverse; the same for pyramid adds and KILLER ×3 labels. Repeats in the same direction are hidden, although those trades still happen: stop lines, result labels, dashboard and alerts are not affected.")
colorBars = input.bool(true, "Color bars by stack", group = grpV)
colBullIn = input.color(#00c853, "Bull", group = grpV, inline = "c")
colBearIn = input.color(#ff1744, "Bear", group = grpV, inline = "c")
colGoldIn = input.color(#ffd600, "Stack", group = grpV, inline = "c")
theme     = input.string("Custom", "Colour theme", options = ["Custom", "Neon", "Ocean", "Mono"], group = grpV,
     tooltip = "Custom uses the three colours above. Neon / Ocean / Mono are ready-made palettes.")
showRes   = input.bool(false, "Closed-trade result labels (R)", group = grpV)
showGlow  = input.bool(false, "Background glow on full stack", group = grpV)
colBull   = theme == "Neon" ? #39ff14 : theme == "Ocean" ? #00b4d8 : theme == "Mono" ? #e6e6e6 : colBullIn
colBear   = theme == "Neon" ? #ff2bd6 : theme == "Ocean" ? #ff6b35 : theme == "Mono" ? #7a7a7a : colBearIn
colGold   = theme == "Neon" ? #fff200 : theme == "Ocean" ? #ffd166 : theme == "Mono" ? #ffffff : colGoldIn

grpD     = "Dashboard"
showDash = input.bool(true, "Show dashboard", group = grpD)
dashPos  = input.string("Top right", "Position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpD)
dashSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = grpD)
costPct  = input.float(0.06, "Cost per side % (stats)", minval = 0.0, step = 0.01, group = grpD)

// ─── Shared series ─────────────────────────────────────────────────────────────
bpd    = 86400.0 / timeframe.in_seconds()
lenA   = math.max(5, int(math.round(dFast * bpd)))
lenB   = math.max(5, int(math.round(dMid * bpd)))
lenC   = math.max(5, int(math.round(dSlow * bpd)))
atr    = ta.atr(atrLen)
gate   = ta.ema(close, gateLen)
gateOk = allowShort and (not gateShort or close < gate)
trL    = ta.highest(high, trLen) - trMult * atr
trS    = ta.lowest(low, trLen) + trMult * atr
cost   = costPct / 100.0
isConf = barstate.isconfirmed

// structure breaks (BOS / CHoCH) on confirmed swing pivots
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
var float msH  = na
var float msL  = na
var bool  msHb = true
var bool  msLb = true
if not na(ph)
    msH  := ph
    msHb := false
if not na(pl)
    msL  := pl
    msLb := false
bosUp = not na(msH) and not msHb and close > msH + 0.05 * atr
bosDn = not na(msL) and not msLb and close < msL - 0.05 * atr
if bosUp
    msHb := true
if bosDn
    msLb := true

// ─── 8-MA consensus per sleeve ─────────────────────────────────────────────────
f_cons(simple int n) =>
    e1 = ta.ema(close, n)
    e2 = ta.ema(e1, n)
    e3 = ta.ema(e2, n)
    m1 = e1
    m2 = ta.sma(close, n)
    m3 = ta.wma(close, n)
    m4 = ta.hma(close, n)
    m5 = ta.rma(close, n)
    m6 = 2.0 * e1 - e2
    m7 = 3.0 * e1 - 3.0 * e2 + e3
    m8 = ta.alma(close, n, 0.85, 6)
    c  = (m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8) / 8.0
    k  = (close > m1 ? 1 : 0) + (close > m2 ? 1 : 0) + (close > m3 ? 1 : 0) + (close > m4 ? 1 : 0) +
         (close > m5 ? 1 : 0) + (close > m6 ? 1 : 0) + (close > m7 ? 1 : 0) + (close > m8 ? 1 : 0)
    [c, k]

[consA, kA] = f_cons(lenA)
[consB, kB] = f_cons(lenB)
[consC, kC] = f_cons(lenC)

f_dir(float cons, int prev) =>
    na(cons) or na(atr) ? prev : close > cons + bandM * atr ? 1 : close < cons - bandM * atr ? -1 : prev

var int dirA = 0
var int dirB = 0
var int dirC = 0
dirA := f_dir(consA, dirA)
dirB := f_dir(consB, dirB)
dirC := f_dir(consC, dirC)

// ─── Shadow book (each sleeve trades independently; results in R per unit) ─────
var float[] stats = array.from(0.0, 0.0, 0.0, 0.0, 0.0)   // units closed, wins, ΣR, Σwin R, Σloss R

f_rec(float r) =>
    array.set(stats, 0, array.get(stats, 0) + 1)
    array.set(stats, 2, array.get(stats, 2) + r)
    if r > 0
        array.set(stats, 1, array.get(stats, 1) + 1)
        array.set(stats, 3, array.get(stats, 3) + r)
    else
        array.set(stats, 4, array.get(stats, 4) - r)
    r

type Sleeve
    string name
    int    pos      = 0
    int    nu       = 0
    float  e1       = na
    float  r1       = na
    float  e2       = na
    float  r2       = na
    int    bar1     = na
    float  stop     = na
    int    pend     = 0
    bool   pendAdd  = false
    bool   pendExit = false
    float  pendStop = na
    float  pendRisk = na
    float  lastR    = na
    int    lastDir  = 0
    string lastWhy  = ""

// close every unit at `px`; returns the combined R (sum over units)
method closeAt(Sleeve s, float px, string why) =>
    ra = (s.pos * (px - s.e1) - cost * (s.e1 + px)) / s.r1
    rt = ra
    if isConf
        f_rec(ra)
    if s.nu == 2
        rb = (s.pos * (px - s.e2) - cost * (s.e2 + px)) / s.r2
        rt += rb
        if isConf
            f_rec(rb)
    if isConf and showRes
        label.new(bar_index, px, (rt >= 0 ? "+" : "") + str.tostring(rt, "#.#") + "R", style = s.pos == 1 ? label.style_label_down : label.style_label_up,
             color = color.new(rt >= 0 ? colBull : colBear, 25), textcolor = color.white, size = size.tiny, tooltip = s.name + " sleeve closed: " + why)
    s.lastR   := rt
    s.lastDir := s.pos
    s.lastWhy := why
    s.pos := 0
    s.nu  := 0
    s.e2  := na
    rt

method onOpen(Sleeve s) =>
    float res = na
    if s.pendExit and s.pos != 0
        res := s.closeAt(open, "flip")
    if s.pend != 0
        if s.pos == 0 and not s.pendAdd
            s.pos  := s.pend
            s.nu   := 1
            s.e1   := open
            s.r1   := math.max(s.pendRisk, syminfo.mintick)
            s.stop := s.pendStop
            s.bar1 := bar_index
        else if s.pos == s.pend and s.pendAdd and s.nu < 2
            s.nu := 2
            s.e2 := open
            s.r2 := math.max(s.pendRisk, syminfo.mintick)
    s.pend     := 0
    s.pendAdd  := false
    s.pendExit := false
    res

method onBar(Sleeve s) =>
    float res = na
    if s.pos == 1
        if open <= s.stop
            res := s.closeAt(open, "stop")
        else if low <= s.stop
            res := s.closeAt(s.stop, "stop")
    else if s.pos == -1
        tpx = tpShort > 0 ? s.e1 - tpShort * s.r1 : na
        if open >= s.stop
            res := s.closeAt(open, "stop")
        else if not na(tpx) and open <= tpx
            res := s.closeAt(open, "target")
        else if high >= s.stop
            res := s.closeAt(s.stop, "stop")
        else if not na(tpx) and low <= tpx
            res := s.closeAt(tpx, "target")
    res

// returns +1/-1 when a new entry is queued, +2/-2 when a pyramid add is queued, 0 otherwise
method onClose(Sleeve s, int d, bool flipUp, bool flipDn) =>
    int sig = 0
    if s.pos == 1
        s.stop := math.max(s.stop, trL)
        if d < 0
            s.pendExit := true
    else if s.pos == -1
        s.stop := math.min(s.stop, trS)
        if d > 0
            s.pendExit := true
    if flipUp and s.pos != 1
        s.pend     := 1
        s.pendAdd  := false
        s.pendStop := close - slMult * atr
        s.pendRisk := slMult * atr
        sig := 1
        if s.pos == -1
            s.pendExit := true
    else if flipDn and gateOk and s.pos != -1
        s.pend     := -1
        s.pendAdd  := false
        s.pendStop := close + slMult * atr
        s.pendRisk := slMult * atr
        sig := -1
        if s.pos == 1
            s.pendExit := true
    else if usePyr and not s.pendExit and s.nu == 1 and ((s.pos == 1 and bosUp) or (s.pos == -1 and bosDn and gateOk))
        ru = s.pos * (close - s.stop)
        if ru > 0
            s.pend     := s.pos
            s.pendAdd  := true
            s.pendRisk := ru
            sig := 2 * s.pos
    sig

var Sleeve A = Sleeve.new("FAST")
var Sleeve B = Sleeve.new("MID")
var Sleeve C = Sleeve.new("SLOW")

xA1 = A.onOpen()
xB1 = B.onOpen()
xC1 = C.onOpen()
xA2 = A.onBar()
xB2 = B.onBar()
xC2 = C.onBar()

flipA_up = isConf and dirA == 1 and nz(dirA[1]) != 1
flipA_dn = isConf and dirA == -1 and nz(dirA[1]) != -1
flipB_up = isConf and dirB == 1 and nz(dirB[1]) != 1
flipB_dn = isConf and dirB == -1 and nz(dirB[1]) != -1
flipC_up = isConf and dirC == 1 and nz(dirC[1]) != 1
flipC_dn = isConf and dirC == -1 and nz(dirC[1]) != -1

int sA = 0
int sB = 0
int sC = 0
if isConf
    sA := A.onClose(dirA, flipA_up, flipA_dn)
    sB := B.onClose(dirB, flipB_up, flipB_dn)
    sC := C.onClose(dirC, flipC_up, flipC_dn)

// exit queued by a trend flip (filled at the next open) and the live stop per sleeve, for alerts
exA = isConf and A.pendExit and A.pos != 0
exB = isConf and B.pendExit and B.pos != 0
exC = isConf and C.pendExit and C.pos != 0
exitAny = exA or exB or exC
stA = A.pos != 0 ? A.stop : na
stB = B.pos != 0 ? B.stop : na
stC = C.pos != 0 ? C.stop : na
stack    = dirA + dirB + dirC
// KILLER score 0-100 (display only): 50 = neutral, each aligned sleeve moves it by ~17 points
kScore   = math.round(50 + stack / 3.0 * 50.0)
units    = A.pos * A.nu + B.pos * B.nu + C.pos * C.nu
fullBull = isConf and stack == 3 and nz(stack[1]) != 3
fullBear = isConf and stack == -3 and nz(stack[1]) != -3 and gateOk
// full-stack labels alternate: a repeat in the direction of the last shown label is hidden (display only)
var int lastFull = 0
lblBull = fullBull and (not altStack or lastFull != 1)
lblBear = fullBear and (not altStack or lastFull != -1)
if fullBull
    lastFull := 1
if fullBear
    lastFull := -1
anyEntry = sA == 1 or sA == -1 or sB == 1 or sB == -1 or sC == 1 or sC == -1
anyAdd   = math.abs(sA) == 2 or math.abs(sB) == 2 or math.abs(sC) == 2
stopHit  = isConf and ((not na(xA2)) or (not na(xB2)) or (not na(xC2)))

// ─── Visuals ──────────────────────────────────────────────────────────────────
f_col(int d, int tr) => d == 1 ? color.new(colBull, tr) : d == -1 ? color.new(colBear, tr) : color.new(color.gray, tr)
stackCol = stack >= 2 ? colBull : stack <= -2 ? colBear : color.gray
pA = plot(showLines or showRib ? consA : na, "Fast", color = showLines ? f_col(dirA, 30) : na, linewidth = 1)
plot(showLines ? consB : na, "Mid", color = f_col(dirB, 15), linewidth = 2)
pC = plot(showLines or showRib ? consC : na, "Slow", color = showLines ? f_col(dirC, 0) : na, linewidth = 3)
fill(pA, pC, color = showRib ? color.new(stackCol, math.abs(stack) == 3 ? 78 : 90) : na, title = "Stack ribbon")
plot(showGate ? gate : na, "Gate EMA", color = color.new(color.gray, 45))
plot(showStops and A.pos != 0 ? A.stop : na, "Fast stop", color = f_col(A.pos, 55), style = plot.style_linebr)
plot(showStops and B.pos != 0 ? B.stop : na, "Mid stop",  color = f_col(B.pos, 40), style = plot.style_linebr)
plot(showStops and C.pos != 0 ? C.stop : na, "Slow stop", color = f_col(C.pos, 25), style = plot.style_linebr, linewidth = 2)
bgcolor(showGlow and math.abs(stack) == 3 ? color.new(stack > 0 ? colBull : colBear, 93) : na, title = "Full-stack glow")
barcolor(colorBars ? (stack >= 2 ? colBull : stack <= -2 ? colBear : color.gray) : na)

// entry and add markers alternate like the full-stack labels (display only; trades, stops and alerts are unchanged)
entL = sA == 1 or sB == 1 or sC == 1
entS = sA == -1 or sB == -1 or sC == -1
addL = anyAdd and units > 0
addS = anyAdd and units < 0
var int lastEnt = 0
var int lastAdd = 0
okL  = entL and (not altStack or lastEnt != 1)
okS  = entS and (not altStack or lastEnt != -1)
okAL = addL and (not altStack or lastAdd != 1)
okAS = addS and (not altStack or lastAdd != -1)
if entL
    lastEnt := 1
if entS
    lastEnt := -1
if addL
    lastAdd := 1
if addS
    lastAdd := -1
plotshape(showFlips and okL and sA == 1,  "Fast long",  shape.triangleup,   location.belowbar, color = f_col(1, 40),  size = size.tiny)
plotshape(showFlips and okL and sB == 1,  "Mid long",   shape.triangleup,   location.belowbar, color = f_col(1, 20),  size = size.small)
plotshape(showFlips and okL and sC == 1,  "Slow long",  shape.triangleup,   location.belowbar, color = f_col(1, 0),   size = size.normal)
plotshape(showFlips and okS and sA == -1, "Fast short", shape.triangledown, location.abovebar, color = f_col(-1, 40), size = size.tiny)
plotshape(showFlips and okS and sB == -1, "Mid short",  shape.triangledown, location.abovebar, color = f_col(-1, 20), size = size.small)
plotshape(showFlips and okS and sC == -1, "Slow short", shape.triangledown, location.abovebar, color = f_col(-1, 0),  size = size.normal)
plotshape(showAdds and okAL, "Add long",  shape.cross, location.belowbar, color = colBull, size = size.tiny)
plotshape(showAdds and okAS, "Add short", shape.cross, location.abovebar, color = colBear, size = size.tiny)
plotshape(showStack and lblBull, "Full stack long",  shape.labelup,   location.belowbar, color = colGold, text = "KILLER ×3", textcolor = color.black, size = size.normal)
plotshape(showStack and lblBear, "Full stack short", shape.labeldown, location.abovebar, color = colGold, text = "KILLER ×3", textcolor = color.black, size = size.normal)

// ─── Dashboard ────────────────────────────────────────────────────────────────
f_pos(s) =>
    switch s
        "Top right"    => position.top_right
        "Bottom right" => position.bottom_right
        "Top left"     => position.top_left
        => position.bottom_left
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small
f_r(float r) => na(r) ? "—" : (r >= 0 ? "+" : "") + str.tostring(r, "#.##") + "R"

var table dash = table.new(f_pos(dashPos), 5, 10, bgcolor = color.new(#0e1117, 8),
     border_color = color.new(#2a2e39, 0), border_width = 1, frame_color = color.new(#2a2e39, 0), frame_width = 1)

f_cell(int c, int r, string t, color tc) =>
    table.cell(dash, c, r, t, text_color = tc, text_size = f_size(dashSize), text_halign = c == 0 ? text.align_left : text.align_center)

f_sleeveRow(int r, Sleeve s, int d, int len, int k) =>
    agree = d >= 0 ? k : 8 - k
    f_cell(0, r, s.name + " (" + str.tostring(len) + ")", color.new(color.white, 25))
    f_cell(1, r, d == 1 ? "▲" : d == -1 ? "▼" : "—", f_col(d, 0))
    f_cell(2, r, s.pos == 0 ? "flat" : (s.pos == 1 ? "L" : "S") + "×" + str.tostring(s.nu), s.pos == 0 ? color.new(color.white, 50) : f_col(s.pos, 0))
    f_cell(3, r, s.pos == 0 ? "—" : str.tostring(s.stop, format.mintick), color.orange)
    openR = s.pos == 0 ? na : (s.pos * (close - s.e1) / s.r1 + (s.nu == 2 ? s.pos * (close - s.e2) / s.r2 : 0.0))
    f_cell(4, r, s.pos == 0 ? str.tostring(agree) + "/8" : f_r(openR), s.pos == 0 ? color.new(color.white, 40) : openR >= 0 ? colBull : colBear)

if showDash and barstate.islast
    tfOk = timeframe.in_seconds() >= 14400 and timeframe.in_seconds() <= 86400
    nT   = array.get(stats, 0)
    winP = nT > 0 ? array.get(stats, 1) / nT * 100 : 0.0
    avgR = nT > 0 ? array.get(stats, 2) / nT : na
    pf   = array.get(stats, 4) > 0 ? array.get(stats, 3) / array.get(stats, 4) : na
    table.cell(dash, 0, 0, "KILLER Lite", text_color = colGold, text_size = f_size(dashSize), text_halign = text.align_left, bgcolor = color.new(#000000, 20))
    table.merge_cells(dash, 1, 0, 4, 0)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = color.white, text_size = f_size(dashSize), bgcolor = color.new(#000000, 20))
    f_cell(0, 1, "Sleeve", color.new(color.white, 50))
    f_cell(1, 1, "Trend", color.new(color.white, 50))
    f_cell(2, 1, "Pos", color.new(color.white, 50))
    f_cell(3, 1, "Stop", color.new(color.white, 50))
    f_cell(4, 1, "Open R", color.new(color.white, 50))
    f_sleeveRow(2, A, dirA, lenA, kA)
    f_sleeveRow(3, B, dirB, lenB, kB)
    f_sleeveRow(4, C, dirC, lenC, kC)
    table.merge_cells(dash, 1, 5, 4, 5)
    f_cell(0, 5, "Stack", color.new(color.white, 25))
    f_cell(1, 5, (stack > 0 ? "+" : "") + str.tostring(stack) + " / 3   ·   units " + (units > 0 ? "+" : "") + str.tostring(units) + " / 6", stackCol)
    table.merge_cells(dash, 1, 6, 4, 6)
    f_cell(0, 6, "Short gate", color.new(color.white, 25))
    f_cell(1, 6, not allowShort ? "shorts OFF" : not gateShort ? "shorts ON" : close < gate ? "below EMA" + str.tostring(gateLen) + " → shorts ON" : "above EMA" + str.tostring(gateLen) + " → longs only", close < gate ? colBear : colBull)
    table.merge_cells(dash, 1, 7, 4, 7)
    f_cell(0, 7, "Sim stats", color.new(color.white, 25))
    f_cell(1, 7, nT > 0 ? str.tostring(nT) + " units · " + str.tostring(winP, "#") + "% win · " + f_r(avgR) + " avg · PF " + (na(pf) ? "∞" : str.tostring(pf, "#.##")) : "no closed trades yet", color.white)
    table.merge_cells(dash, 1, 8, 4, 8)
    f_cell(0, 8, "Timeframe", color.new(color.white, 25))
    f_cell(1, 8, tfOk ? "✓ validated (4H – 1D)" : "⚠ outside 4H – 1D — not validated", tfOk ? colBull : color.orange)
    table.merge_cells(dash, 1, 9, 4, 9)
    f_cell(0, 9, "KILLER score", color.new(color.white, 25))
    f_cell(1, 9, str.tostring(kScore) + " / 100   ·   " + (kScore >= 80 ? "strong bull" : kScore >= 60 ? "bull" : kScore > 40 ? "neutral" : kScore > 20 ? "bear" : "strong bear"),
         kScore >= 60 ? colBull : kScore <= 40 ? colBear : color.white)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(fullBull, "KILLER Lite · Full stack LONG", "KILLER Lite ×3 LONG {{ticker}} ({{interval}}) close {{close}}")
alertcondition(fullBear, "KILLER Lite · Full stack SHORT", "KILLER Lite ×3 SHORT {{ticker}} ({{interval}}) close {{close}}")
alertcondition(sA == 1 or sB == 1 or sC == 1, "KILLER Lite · Sleeve long entry", "KILLER Lite sleeve LONG {{ticker}} ({{interval}}) close {{close}}")
alertcondition(sA == -1 or sB == -1 or sC == -1, "KILLER Lite · Sleeve short entry", "KILLER Lite sleeve SHORT {{ticker}} ({{interval}}) close {{close}}")
alertcondition(anyAdd, "KILLER Lite · Pyramid add", "KILLER Lite ADD {{ticker}} ({{interval}}) close {{close}}")
alertcondition(stopHit, "KILLER Lite · Stop / target hit", "KILLER Lite STOP/TARGET {{ticker}} ({{interval}})")
alertcondition(exitAny, "KILLER Lite · Sleeve exit (trend flip)", "KILLER Lite EXIT on trend flip {{ticker}} ({{interval}}) — closes at the next open")

f_msg(string what, Sleeve s, int d) =>
    "KILLER Lite " + what + " " + s.name + " " + (d > 0 ? "LONG" : "SHORT") + " " + syminfo.ticker + " " + timeframe.period +
     " | entry≈" + str.tostring(close, format.mintick) + " | stop " + str.tostring(s.pend != 0 and not s.pendAdd ? s.pendStop : s.stop, format.mintick) +
     " | stack " + str.tostring(stack)
f_ev(string what, Sleeve s, float px) =>
    "KILLER Lite " + what + " " + s.name + " " + syminfo.ticker + " " + timeframe.period + " | price " + str.tostring(px, format.mintick)
// one alert() per bar close with every event: ENTRY / ADD, EXIT (trend flip, filled at the next open), STOP_UPDATE (trail moved), STOP_HIT
evs = array.new<string>()
if isConf
    if not na(xA2)
        evs.push(f_ev("STOP_HIT", A, close))
    if exA
        evs.push(f_ev("EXIT", A, close))
    if sA != 0
        evs.push(f_msg(math.abs(sA) == 2 ? "ADD" : "ENTRY", A, sA))
    if A.pos != 0 and not A.pendExit and not na(stA[1]) and stA != stA[1]
        evs.push(f_ev("STOP_UPDATE", A, A.stop))
    if not na(xB2)
        evs.push(f_ev("STOP_HIT", B, close))
    if exB
        evs.push(f_ev("EXIT", B, close))
    if sB != 0
        evs.push(f_msg(math.abs(sB) == 2 ? "ADD" : "ENTRY", B, sB))
    if B.pos != 0 and not B.pendExit and not na(stB[1]) and stB != stB[1]
        evs.push(f_ev("STOP_UPDATE", B, B.stop))
    if not na(xC2)
        evs.push(f_ev("STOP_HIT", C, close))
    if exC
        evs.push(f_ev("EXIT", C, close))
    if sC != 0
        evs.push(f_msg(math.abs(sC) == 2 ? "ADD" : "ENTRY", C, sC))
    if C.pos != 0 and not C.pendExit and not na(stC[1]) and stC != stC[1]
        evs.push(f_ev("STOP_UPDATE", C, C.stop))
if evs.size() > 0
    alert(array.join(evs, "\n"), alert.freq_once_per_bar_close)
````

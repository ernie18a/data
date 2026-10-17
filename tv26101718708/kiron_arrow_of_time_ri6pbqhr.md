# KIRON Arrow of Time

- url: https://www.tradingview.com/script/ri6pbQhr-KIRON-Arrow-of-Time/
- type: indicator
- pine_id: PUB;cac75cf954f1476fb52e2e1ff6a18eba
- version: 1.0

## Description

OVERVIEW
Most indicators measure where price went or how fast it got there. KIRON Arrow of Time measures something different: whether price behaves the same way going up as it does going down.

In a balanced market, a chart played backwards looks statistically the same as one played forwards: rallies and declines have the same shape. When one side of the market is consistently more aggressive, that symmetry breaks. One direction starts to travel like an elevator (fast, sharp legs) while the other travels like stairs (slow, grinding legs). In physics this is called time-irreversibility. This indicator measures the direction and strength of that asymmetry (the "Arrow") and compares it with the direction price has actually drifted.

HOW IT WORKS
1) Bar asymmetry (short-term)
Price changes over three lags (1, 3 and 8 bars by default) are normalised by ATR, and their skewness is measured over a rolling window (120 bars). The skew is centred, so a steady trend on its own does not register; only the shape of the moves does. Positive = the sharp moves are up-moves. Negative = the sharp moves are down-moves.

2) Swing-speed asymmetry (structural)
An internal ATR-based zigzag (1.5 × ATR reversal) tracks swings. For each completed leg it measures speed in ATR per bar, then averages the most recent up-legs and down-legs (6 each, plus the live leg). The log of the up/down speed ratio gives the swing component.

3) The Arrow
Both components are squashed to a -100…+100 scale, blended (weights adjustable) and smoothed. This is the Arrow, shown as columns in the pane.
- Above +band (green): up-moves are the "elevator", aggressive buying.
- Below -band (red): down-moves are the "elevator", aggressive selling.
- Inside the band (grey): no meaningful asymmetry.

4) Drift
The white line shows where price has actually gone over the drift window (60 bars), ATR-normalised onto the same -100…+100 scale.

STATES (pane background)
The Arrow and Drift are combined into one regime label:
- DRIVEN ↑ / ↓: aggression and drift agree.
- FRAGILE ↑: price drifting up, but down-moves are the faster ones (stairs up, elevator down).
- FRAGILE ↓: price drifting down, but up-moves are the faster ones (stairs down, elevator up).
- COILED ↑ / ↓: strong asymmetry while price has not yet moved.
- CONFLICT: the bar and swing components are both strong but point in opposite directions, so the measurements disagree.
- REVERSIBLE: no meaningful asymmetry.
States use hysteresis (they exit at a fraction of the entry level) and a persistence filter (a new state must hold for N bars) to reduce flicker.

EVENTS (plotted on the price chart, confirmed on bar close, no repainting)
- IGN ▲ / ▼ (Ignite): a Coiled state transitions into the matching Driven state.
- FRX ✕ (Fracture): a Fragile state arms the event; it prints when the zigzag confirms the first swing reversal against the drift.
- Coil dots (pane): entry into a Coiled state.
A cooldown prevents the same event from repeating within N bars.

READOUT TABLE
State and a short description, Arrow value, each component's contribution (bar and swing), average up-leg and down-leg speed (ATR/bar), the speed ratio and Drift. The component rows make it visible when the two measurements agree and when they do not.

HOW TO USE IT
KIRON AOT is a context tool. It describes how price is moving: whether a trend is carried by aggressive, fast moves or is grinding with sharp counter-moves against it. Typical uses:
- Judging the character of a trend before applying your own entry method.
- Spotting when a trend's internal structure changes (e.g. DRIVEN turning FRAGILE).
- Standing aside when the components are in CONFLICT.
The IGN and FRX markers flag changes in that structure. They are not standalone buy or sell signals and should be combined with your own levels, structure and risk management.

SETTINGS
Arrow engine: ATR length, asymmetry window, the three lags, swing threshold (× ATR), swing legs averaged, component weights and sensitivities, Arrow smoothing.
States & signals: drift window, Arrow and Drift entry bands, exit level (hysteresis), persistence, conflict threshold, fracture window, ignite-from-coil option, cooldown, display toggles.
Colours: fully customisable.

ALERTS
Ignite ▲ / ▼, Fracture top / bottom, Coil, Conflict, plus a state-change alert via "Any alert() function call".

NOTES & LIMITATIONS
- The indicator needs a warm-up period (asymmetry window plus at least two swings in each direction) before it shows a reading.
- Readings depend on timeframe and instrument; the default settings were developed on XAUUSD 15m.
- This is an analytical tool, not a trading system. Past behaviour of any reading does not guarantee future results. Always use your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KironKavanagh

//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// KIRON Arrow of Time (KIRON AOT) · v1.2
// Measures time-irreversibility of price: is one direction travelled by
// aggressive "elevators" and the other by passive "stairs"? Then compares that
// arrow of aggression with where price actually drifted.
// v1.1: hysteresis + persistence on states, FRX = fragile + swing flip,
//       IGN from Coil (default), component readout.
// v1.2: CONFLICT state — bar and swing components both strong but opposed.
// ─────────────────────────────────────────────────────────────────────────────
indicator("KIRON Arrow of Time", shorttitle = "KIRON AOT", overlay = false, precision = 1)

// ── Inputs ──────────────────────────────────────────────────────────────────
grpE = "Arrow engine"
atrLen    = input.int(14,    "ATR length",                     minval = 2,                 group = grpE)
win       = input.int(120,   "Asymmetry window (bars)",        minval = 20,                group = grpE)
lagA      = input.int(1,     "Lags A / B / C",                 minval = 1, inline = "L",   group = grpE)
lagB      = input.int(3,     "",                               minval = 1, inline = "L",   group = grpE)
lagC      = input.int(8,     "",                               minval = 1, inline = "L",   group = grpE)
zzMult    = input.float(1.5, "Swing threshold (× ATR)",        minval = 0.2, step = 0.1,   group = grpE)
legsN     = input.int(6,     "Swing legs averaged per side",   minval = 2, maxval = 50,    group = grpE)
wStat     = input.float(1.0, "Weight · bar asymmetry",         minval = 0.0, step = 0.1,   group = grpE)
wLeg      = input.float(1.0, "Weight · swing-speed asymmetry", minval = 0.0, step = 0.1,   group = grpE)
sensStat  = input.float(2.0, "Sensitivity · bar asymmetry",    minval = 0.1, step = 0.1,   group = grpE)
sensLeg   = input.float(1.5, "Sensitivity · swing speed",      minval = 0.1, step = 0.1,   group = grpE)
smoothLen = input.int(5,     "Arrow smoothing",                minval = 1,                 group = grpE)

grpS = "States & signals"
driftLen    = input.int(60,     "Drift window (bars)",                  minval = 5,                   group = grpS)
band        = input.float(20.0, "Arrow entry band (±)",                 minval = 1.0, maxval = 90.0,  group = grpS)
driftBand   = input.float(25.0, "Drift entry band (±)",                 minval = 1.0, maxval = 90.0,  group = grpS)
hystK       = input.float(0.6,  "Exit level (fraction of entry band)",  minval = 0.1, maxval = 1.0, step = 0.05, group = grpS)
persist     = input.int(3,      "State persistence (bars)",             minval = 1,                   group = grpS)
conflictLvl = input.float(30.0, "Conflict level (each component ≥)",    minval = 5.0, maxval = 95.0,  group = grpS)
fracWin     = input.int(30,     "Fracture window after Fragile (bars)", minval = 1,                   group = grpS)
ignCoilOnly = input.bool(true,  "Ignite only out of Coil",                                            group = grpS)
cooldown    = input.int(10,     "Signal cooldown (bars)",               minval = 0,                   group = grpS)
showSig     = input.bool(true,  "Signals on price chart",                                             group = grpS)
showCoil    = input.bool(true,  "Coil dots in pane",                                                  group = grpS)
showBg      = input.bool(true,  "Shade pane by state",                                                group = grpS)
colorBars   = input.bool(false, "Colour price bars by state",                                         group = grpS)
showTable   = input.bool(true,  "Readout table",                                                      group = grpS)

grpC = "Colours"
cUp    = input.color(#00C2A8, "Forward ↑",  group = grpC)
cDn    = input.color(#FF4D6D, "Forward ↓",  group = grpC)
cFrag  = input.color(#FFB020, "Fragile",    group = grpC)
cCoil  = input.color(#8E7CFF, "Coiled",     group = grpC)
cConf  = input.color(#C9D1E0, "Conflict",   group = grpC)
cRev   = input.color(#7A8394, "Reversible", group = grpC)
cDrift = input.color(#E6E9EF, "Drift line", group = grpC)

// ── Helpers ─────────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)

f_tanh(float x) =>
    float xc = math.max(math.min(x, 20.0), -20.0)
    float e  = math.exp(2.0 * xc)
    (e - 1.0) / (e + 1.0)

// Central skewness of ATR-normalised k-bar increments = time-reversal asymmetry.
f_skew(simple int k) =>
    float d  = (close - close[k]) / (atr * math.sqrt(k))
    float m1 = ta.sma(d, win)
    float m2 = ta.sma(d * d, win)
    float m3 = ta.sma(d * d * d, win)
    float c2 = m2 - m1 * m1
    float c3 = m3 - 3.0 * m1 * m2 + 2.0 * m1 * m1 * m1
    c2 > 1e-10 ? c3 / math.pow(c2, 1.5) : na

f_push(array<float> a, float v) =>
    a.push(v)
    if a.size() > legsN
        a.shift()

f_mean(array<float> a, float live) =>
    float s = a.size() > 0 ? a.sum() : 0.0
    int   n = a.size()
    if not na(live)
        s += live
        n += 1
    n > 0 ? s / n : na

f_fmt(float x, string fmt) =>
    na(x) ? "—" : str.tostring(x, fmt)

f_fmtS(float x, string fmt) =>
    na(x) ? "—" : (x > 0 ? "+" : "") + str.tostring(x, fmt)

f_stateCol(int s) =>
    switch
        s == 1           => cUp
        s == -1          => cDn
        math.abs(s) == 2 => cFrag
        math.abs(s) == 3 => cCoil
        s == 4           => cConf
        => cRev

f_stateName(int s) =>
    switch
        s == 1  => "DRIVEN ↑"
        s == -1 => "DRIVEN ↓"
        s == 2  => "FRAGILE ↑"
        s == -2 => "FRAGILE ↓"
        s == 3  => "COILED ↑"
        s == -3 => "COILED ↓"
        s == 4  => "CONFLICT"
        => "REVERSIBLE"

f_stateHint(int s, float cb) =>
    switch
        s == 1  => "Aggressive buyers carrying price"
        s == -1 => "Aggressive sellers carrying price"
        s == 2  => "Stairs up, elevator down: flush risk"
        s == -2 => "Stairs down, elevator up: squeeze risk"
        s == 3  => "Buy aggression, no displacement yet"
        s == -3 => "Sell aggression, no displacement yet"
        s == 4  => (cb > 0 ? "Bar spikes ↑ vs swing elevator ↓" : "Bar spikes ↓ vs swing elevator ↑") + ": stand aside"
        => "No arrow: equilibrium, fade extremes"

// ── 1. Bar-level time asymmetry (multi-lag) ─────────────────────────────────
skA = f_skew(lagA)
skB = f_skew(lagB)
skC = f_skew(lagC)
nSk = (na(skA) ? 0 : 1) + (na(skB) ? 0 : 1) + (na(skC) ? 0 : 1)
barAsym = nSk > 0 ? (nz(skA) + nz(skB) + nz(skC)) / nSk : na

// ── 2. Swing-speed asymmetry (elevator vs stairs) ───────────────────────────
var int   zDir      = 0
var float zExt      = na
var int   zExtBar   = 0
var float zStart    = na
var int   zStartBar = 0
var array<float> upSpd = array.new<float>()
var array<float> dnSpd = array.new<float>()

thr = atr * zzMult
if not na(atr) and atr > 0
    if zDir == 0
        zDir      := close >= open ? 1 : -1
        zExt      := zDir == 1 ? high : low
        zExtBar   := bar_index
        zStart    := zDir == 1 ? low : high
        zStartBar := bar_index
    else if zDir == 1
        if high > zExt
            zExt    := high
            zExtBar := bar_index
        else if low < zExt - thr
            if zExt - zStart >= thr
                f_push(upSpd, ((zExt - zStart) / atr) / math.max(1, zExtBar - zStartBar))
            zStart    := zExt
            zStartBar := zExtBar
            zDir      := -1
            zExt      := low
            zExtBar   := bar_index
    else
        if low < zExt
            zExt    := low
            zExtBar := bar_index
        else if high > zExt + thr
            if zStart - zExt >= thr
                f_push(dnSpd, ((zStart - zExt) / atr) / math.max(1, zExtBar - zStartBar))
            zStart    := zExt
            zStartBar := zExtBar
            zDir      := 1
            zExt      := high
            zExtBar   := bar_index

liveUp = zDir == 1  and zExt - zStart >= thr ? ((zExt - zStart) / atr) / math.max(1, zExtBar - zStartBar) : na
liveDn = zDir == -1 and zStart - zExt >= thr ? ((zStart - zExt) / atr) / math.max(1, zExtBar - zStartBar) : na

upSpeed    = f_mean(upSpd, liveUp)
dnSpeed    = f_mean(dnSpd, liveDn)
speedRatio = upSpeed > 0 and dnSpeed > 0 ? upSpeed / dnSpeed : na
legAsym    = na(speedRatio) ? na : math.log(speedRatio)

zzFlipDn = zDir == -1 and zDir[1] == 1
zzFlipUp = zDir == 1  and zDir[1] == -1

// ── 3. The Arrow ────────────────────────────────────────────────────────────
maxLag = math.max(lagA, math.max(lagB, lagC))
ready  = bar_index > win + maxLag + atrLen and upSpd.size() >= 2 and dnSpd.size() >= 2

cStat = na(barAsym) ? na : f_tanh(barAsym * sensStat)
cLeg  = na(legAsym) ? na : f_tanh(legAsym * sensLeg)
wS    = na(cStat) ? 0.0 : wStat
wL    = na(cLeg)  ? 0.0 : wLeg
rawArrow = wS + wL > 0 ? 100.0 * (wS * nz(cStat) + wL * nz(cLeg)) / (wS + wL) : 0.0
arrowS   = ta.ema(rawArrow, smoothLen)
arrow    = ready ? arrowS : na

// Conflict: both components strong, opposite signs (only when both are weighted)
compBar   = na(cStat) ? na : 100.0 * cStat
compSwing = na(cLeg)  ? na : 100.0 * cLeg
conflict  = ready and wStat > 0 and wLeg > 0 and not na(compBar) and not na(compSwing) and math.abs(compBar) >= conflictLvl and math.abs(compSwing) >= conflictLvl and math.sign(compBar) != math.sign(compSwing)

// ── 4. Drift (where price actually went) ────────────────────────────────────
driftZ = (close - close[driftLen]) / (atr * math.sqrt(driftLen))
drift  = na(driftZ) ? na : 100.0 * f_tanh(driftZ * 0.75)

// ── 5. State: arrow × drift, hysteresis + persistence ───────────────────────
var int aReg = 0
var int dReg = 0

if ready and not na(arrow)
    float aExit = band * hystK
    if arrow >= band
        aReg := 1
    else if arrow <= -band
        aReg := -1
    else if (aReg == 1 and arrow < aExit) or (aReg == -1 and arrow > -aExit)
        aReg := 0
else
    aReg := 0

if not na(drift)
    float dExit = driftBand * hystK
    if drift >= driftBand
        dReg := 1
    else if drift <= -driftBand
        dReg := -1
    else if (dReg == 1 and drift < dExit) or (dReg == -1 and drift > -dExit)
        dReg := 0

int rawState = 0
if aReg != 0
    rawState := dReg == 1 ? (aReg == 1 ? 1 : 2) : dReg == -1 ? (aReg == -1 ? -1 : -2) : (aReg == 1 ? 3 : -3)
else if conflict
    rawState := 4

var int state     = 0
var int cand      = 0
var int candCount = 0
if rawState == cand
    candCount += 1
else
    cand      := rawState
    candCount := 1
if candCount >= persist
    state := cand

// ── 6. Signals (bar-close confirmed) ────────────────────────────────────────
conf     = barstate.isconfirmed
bsFragUp = ta.barssince(state == 2)
bsFragDn = ta.barssince(state == -2)

// IGN: aggression that was loaded (Coil) now gets displacement
igLraw = conf and state == 1  and state[1] != 1  and (ignCoilOnly ? state[1] == 3  : (state[1] == 0 or state[1] == 3))
igSraw = conf and state == -1 and state[1] != -1 and (ignCoilOnly ? state[1] == -3 : (state[1] == 0 or state[1] == -3))

// FRX: Fragile armed, fires on the first opposing swing (the elevator starts)
var bool armT = false
var bool armB = false
if state == 2 and state[1] != 2
    armT := true
if state == -2 and state[1] != -2
    armB := true
if armT and nz(bsFragUp, 1000000) > fracWin
    armT := false
if armB and nz(bsFragDn, 1000000) > fracWin
    armB := false

frTraw = conf and armT and zzFlipDn
frBraw = conf and armB and zzFlipUp

var int lastIgL = -1000000
var int lastIgS = -1000000
var int lastFrT = -1000000
var int lastFrB = -1000000

igniteL = igLraw and bar_index - lastIgL > cooldown
igniteS = igSraw and bar_index - lastIgS > cooldown
fracT   = frTraw and bar_index - lastFrT > cooldown
fracB   = frBraw and bar_index - lastFrB > cooldown
if igniteL
    lastIgL := bar_index
if igniteS
    lastIgS := bar_index
if fracT
    lastFrT := bar_index
    armT    := false
if fracB
    lastFrB := bar_index
    armB    := false

coilU = conf and state == 3  and state[1] != 3
coilD = conf and state == -3 and state[1] != -3

// ── 7. Visuals ──────────────────────────────────────────────────────────────
arrowCol = na(arrow) ? na : state == 4 ? color.new(cConf, 30) : aReg == 0 ? color.new(cRev, 40) : arrow > 0 ? cUp : cDn
plot(arrow, title = "Arrow", color = arrowCol, style = plot.style_columns)
plot(drift, title = "Drift", color = cDrift, linewidth = 2)
hline(0,     "Zero",   color = color.new(#7A8394, 50), linestyle = hline.style_solid)
hline(band,  "Band +", color = color.new(#7A8394, 60), linestyle = hline.style_dashed)
hline(-band, "Band −", color = color.new(#7A8394, 60), linestyle = hline.style_dashed)

bgcolor(showBg and state != 0 ? color.new(f_stateCol(state), state == 4 ? 82 : 88) : na)
barcolor(colorBars and ready ? f_stateCol(state) : na)

plotshape(showSig and igniteL, title = "Ignite ▲",          style = shape.triangleup,   location = location.belowbar, color = cUp,   size = size.small, text = "IGN", textcolor = cUp,   force_overlay = true)
plotshape(showSig and igniteS, title = "Ignite ▼",          style = shape.triangledown, location = location.abovebar, color = cDn,   size = size.small, text = "IGN", textcolor = cDn,   force_overlay = true)
plotshape(showSig and fracT,   title = "Fracture (top)",    style = shape.xcross,       location = location.abovebar, color = cFrag, size = size.small, text = "FRX", textcolor = cFrag, force_overlay = true)
plotshape(showSig and fracB,   title = "Fracture (bottom)", style = shape.xcross,       location = location.belowbar, color = cFrag, size = size.small, text = "FRX", textcolor = cFrag, force_overlay = true)
plotshape(showCoil and coilU,  title = "Coil ↑", style = shape.circle, location = location.bottom, color = cCoil, size = size.tiny)
plotshape(showCoil and coilD,  title = "Coil ↓", style = shape.circle, location = location.top,    color = cCoil, size = size.tiny)

// ── 8. Readout ──────────────────────────────────────────────────────────────
var table tb = table.new(position.top_right, 2, 10, bgcolor = color.new(#0B0F17, 5), frame_color = color.new(#2A3140, 0), frame_width = 1, border_color = color.new(#1A2030, 0), border_width = 1)

f_row(int r, string k, string v, color vc) =>
    table.cell(tb, 0, r, k, text_color = #9AA3B2, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if showTable and barstate.isfirst
    table.cell(tb, 0, 0, "KIRON · ARROW OF TIME v1.2", text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tb, 0, 0, 1, 0)
    table.merge_cells(tb, 0, 2, 1, 2)

if showTable and barstate.islast
    sc = f_stateCol(state)
    f_row(1, "State", ready ? f_stateName(state) : "WARMING UP", sc)
    table.cell(tb, 0, 2, ready ? f_stateHint(state, nz(compBar)) + (armT ? " · FRX armed ▼" : armB ? " · FRX armed ▲" : "") : "Need more bars / swings", text_color = sc, text_size = size.tiny, text_halign = text.align_left)
    f_row(3, "Arrow",              f_fmtS(arrow, "0.0"), na(arrow) ? cRev : arrow > 0 ? cUp : cDn)
    f_row(4, "Component · bar",    f_fmtS(compBar, "0.0"),   conflict ? cConf : color.white)
    f_row(5, "Component · swing",  f_fmtS(compSwing, "0.0"), conflict ? cConf : color.white)
    f_row(6, "Up-leg speed",       f_fmt(upSpeed, "0.00") + " ATR/bar", cUp)
    f_row(7, "Down-leg speed",     f_fmt(dnSpeed, "0.00") + " ATR/bar", cDn)
    f_row(8, "Speed ratio ↑/↓",    f_fmt(speedRatio, "0.00") + "×",     color.white)
    f_row(9, "Drift",              f_fmtS(drift, "0.0"), cDrift)

// ── 9. Alerts ───────────────────────────────────────────────────────────────
alertcondition(igniteL, "AOT · Ignite ▲",          "KIRON AOT · Ignite ▲ · {{ticker}} {{interval}} @ {{close}}")
alertcondition(igniteS, "AOT · Ignite ▼",          "KIRON AOT · Ignite ▼ · {{ticker}} {{interval}} @ {{close}}")
alertcondition(fracT,   "AOT · Fracture (top)",    "KIRON AOT · Fracture top (fragile + swing flip) · {{ticker}} {{interval}} @ {{close}}")
alertcondition(fracB,   "AOT · Fracture (bottom)", "KIRON AOT · Fracture bottom (fragile + swing flip) · {{ticker}} {{interval}} @ {{close}}")
alertcondition(coilU or coilD, "AOT · Coil",       "KIRON AOT · Coil forming · {{ticker}} {{interval}} @ {{close}}")
alertcondition(state == 4 and state[1] != 4 and conf, "AOT · Conflict", "KIRON AOT · Conflict (stand aside) · {{ticker}} {{interval}} @ {{close}}")

if conf and ready and state != state[1]
    alert("KIRON AOT · " + syminfo.ticker + " · state → " + f_stateName(state), alert.freq_once_per_bar_close)
````

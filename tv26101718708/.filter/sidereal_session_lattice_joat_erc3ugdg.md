# Sidereal Session Lattice [JOAT]

- url: https://www.tradingview.com/script/eRc3UgDg-Sidereal-Session-Lattice-JOAT/
- type: indicator
- pine_id: PUB;9b3d8f74454642d49f3d2868f80af58a
- version: 1.0

## Description

[b]Sidereal Session Lattice [JOAT][/b]

[b]Introduction[/b]

Sidereal Session Lattice is an open-source intraday session-orbit indicator. It maps session phase, VWAP drift, volatility harmonics, entropy, and anomaly pressure into adaptive orbit bands and compact phase cells.

The indicator is designed to answer a session-context question: is price moving with the current session phase, stretching beyond its orbit, or compressing into balance?

[image]https://www.tradingview.com/x/nkBwwAVs/[/image]

[b]Core Concepts[/b]

[b]1. Session Phase[/b]

Each active session is counted bar by bar. The bar count is converted into a normalized phase value from 0 to 1.

[b]2. Harmonic Orbit[/b]

The phase value is transformed with sine waves to create an intraday harmonic component. This does not predict price; it creates a reference curve for studying session rhythm.

[b]3. VWAP Drift[/b]

The script tracks the distance between price and session VWAP, then normalizes the drift by ATR.

[b]4. Entropy and Anomaly Rank[/b]

The script compares recent up/down candle energy and return magnitude to estimate balance and anomaly pressure.

[b]5. Phase Cells[/b]

Compact cells mark upper-orbit events, lower-orbit events, and balance compression.

[b]Features[/b]

[list]
[*][b]Session phase model:[/b] Tracks where the market is inside the active session cycle
[*][b]VWAP drift:[/b] Measures price displacement from session VWAP
[*][b]Harmonic orbit bands:[/b] Adaptive bands based on phase, volatility, and drift
[*][b]Entropy score:[/b] Measures up/down energy balance
[*][b]Anomaly rank:[/b] Highlights unusual movement relative to recent behavior
[*][b]Phase cells:[/b] Compact boxes show session-orbit events
[*][b]Dashboard:[/b] Shows phase, lattice score, drift, entropy, anomaly, and current state
[/list]

[b]Input Parameters[/b]

[list]
[*]Primary session defines the active session window
[*]Cycle bars controls the phase cycle length
[*]Drift smoothing controls VWAP drift smoothing
[*]Entropy memory controls bid/ask balance memory
[*]Anomaly memory controls return-rank comparison
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the phase state[/b]

The dashboard names the current session phase, such as open drive, balance, or close risk.

[b]Step 2: Watch orbit events[/b]

Upper and lower orbit cells mark when price stretches beyond the adaptive session orbit.

[b]Step 3: Use entropy for balance context[/b]

High entropy with low anomaly often indicates balanced conditions.

[b]Indicator Limitations[/b]

[list]
[*]The harmonic orbit is a reference model, not a forecast
[*]Session behavior varies by symbol and exchange hours
[*]Entropy and anomaly values are derived from chart bars and may change with timeframe
[/list]

[b]Originality Statement[/b]

Sidereal Session Lattice combines session phase, VWAP drift, harmonic references, entropy, and anomaly ranking. It is not a standard session high/low tool; it provides a structured way to study intraday rhythm and displacement.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Session models can fail in news, gaps, and unusual liquidity conditions.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Sidereal Session Lattice [JOAT]", shorttitle="SIL [JOAT]", overlay=true, max_lines_count=260, max_boxes_count=160, max_labels_count=120, max_bars_back=2200)

// Sidereal Session Lattice [JOAT]
// Rebuilt as an intraday orbital quant map. It models session phase, VWAP drift,
// volatility harmonics, entropy, and anomaly pressure without old grid ladders.

groupCore = "Session Orbit"
string sessionInput = input.session("0930-1600", "Primary session", group=groupCore)
int cycleBars = input.int(96, "Cycle bars", minval=20, maxval=500, group=groupCore)
int driftLen = input.int(34, "Drift smoothing", minval=5, maxval=160, group=groupCore)
int entropyLen = input.int(55, "Entropy memory", minval=10, maxval=240, group=groupCore)
int anomalyLen = input.int(144, "Anomaly memory", minval=30, maxval=500, group=groupCore)
float phaseGate = input.float(63.0, "Phase anomaly gate", minval=30.0, maxval=95.0, step=0.5, group=groupCore)

groupVisual = "Visual System"
bool showOrbitBands = input.bool(true, "Show orbit bands", group=groupVisual)
bool showPhaseCells = input.bool(true, "Show phase cells", group=groupVisual)
bool showDashboard = input.bool(true, "Show dashboard", group=groupVisual)
bool paintCandles = input.bool(true, "Paint session phase candles", group=groupVisual)
int cellLife = input.int(40, "Phase cell life", minval=8, maxval=180, group=groupVisual)
int maxCells = input.int(28, "Maximum phase cells", minval=4, maxval=100, group=groupVisual)

color C_CYAN = color.rgb(8, 239, 251)
color C_MAGENTA = color.rgb(217, 2, 255)
color C_GOLD = color.rgb(255, 200, 0)
color C_TEAL = color.rgb(38, 166, 154)
color C_CORAL = color.rgb(239, 83, 80)
color C_VIOLET = color.rgb(125, 92, 255)
color C_PANEL = color.rgb(13, 16, 26)
color C_PANEL_2 = color.rgb(20, 24, 38)
color C_TEXT = color.rgb(226, 232, 240)
color C_DIM = color.rgb(130, 140, 160)

float PI = 3.14159265359

f_clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_safeDiv(float num, float den, float fallback) =>
    math.abs(den) > 0.0000001 ? num / den : fallback

f_phaseName(float phase) =>
    phase < 0.125 ? "OPEN DRIVE" : phase < 0.25 ? "FIRST MEAN" : phase < 0.375 ? "MID EXPAND" : phase < 0.5 ? "BALANCE" : phase < 0.625 ? "SECOND DRIVE" : phase < 0.75 ? "LATE MEAN" : phase < 0.875 ? "CLOSE RISK" : "RESET"

bool inSession = not na(time(timeframe.period, sessionInput))
bool newSession = inSession and inSession[1] != true
var int sessionBar = 0
if newSession
    sessionBar := 0
else if inSession
    sessionBar += 1

var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var float sessionVol = 0.0
var float sessionPv = 0.0
if newSession
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
    sessionVol := volume
    sessionPv := hlc3 * volume
else if inSession
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow := math.min(nz(sessionLow, low), low)
    sessionVol += volume
    sessionPv += hlc3 * volume

float sessionVwap = f_safeDiv(sessionPv, sessionVol, hlc3)
float sessionRange = math.max(nz(sessionHigh, high) - nz(sessionLow, low), syminfo.mintick)
float phase = inSession ? (sessionBar % cycleBars) / cycleBars : 0.0
float angle = phase * 2.0 * PI
float harmonicOne = math.sin(angle)
float harmonicTwo = math.sin(angle * 2.0 + PI * 0.25)
float harmonicBlend = harmonicOne * 0.62 + harmonicTwo * 0.38

float atr = ta.atr(21)
float drift = ta.ema(close - sessionVwap, driftLen)
float driftAtr = f_safeDiv(drift, atr, 0.0)
float rangePosition = f_safeDiv(close - nz(sessionLow, low), sessionRange, 0.5)
float orbitWidth = atr * (0.75 + math.abs(harmonicBlend) * 0.55 + math.abs(driftAtr) * 0.16)
float orbitMean = sessionVwap + harmonicBlend * orbitWidth * 0.42
float upperOrbit = orbitMean + orbitWidth
float lowerOrbit = orbitMean - orbitWidth
float upperOuter = orbitMean + orbitWidth * 1.72
float lowerOuter = orbitMean - orbitWidth * 1.72

float ret = close[1] != 0.0 ? math.log(close / close[1]) : 0.0
float retDev = ta.stdev(ret, entropyLen)
float absRet = math.abs(ret)
float anomalyRaw = f_safeDiv(absRet, ta.sma(absRet, anomalyLen), 1.0)
float anomalyRankRaw = ta.percentrank(anomalyRaw, anomalyLen)
float anomalyRank = na(anomalyRankRaw) ? 50.0 : anomalyRankRaw

float upEnergy = math.max(close - open, 0.0) * volume
float dnEnergy = math.max(open - close, 0.0) * volume
float upShare = f_safeDiv(math.sum(upEnergy, entropyLen), math.sum(upEnergy + dnEnergy, entropyLen), 0.5)
float dnShare = 1.0 - upShare
float entropy = 0.0
entropy += upShare > 0.0 ? -upShare * math.log(upShare) : 0.0
entropy += dnShare > 0.0 ? -dnShare * math.log(dnShare) : 0.0
float entropyPct = f_clamp(entropy / math.log(2.0) * 100.0, 0.0, 100.0)

float phasePressure = f_clamp((rangePosition - 0.5) * 100.0 + driftAtr * 12.0 + harmonicBlend * 22.0, -100.0, 100.0)
float latticeScore = f_clamp(anomalyRank * 0.38 + math.abs(phasePressure) * 0.34 + (100.0 - entropyPct) * 0.28, 0.0, 100.0)
bool upperPhaseEvent = barstate.isconfirmed and inSession and close > upperOrbit and phasePressure > 0.0 and latticeScore >= phaseGate
bool lowerPhaseEvent = barstate.isconfirmed and inSession and close < lowerOrbit and phasePressure < 0.0 and latticeScore >= phaseGate
bool balanceCompression = barstate.isconfirmed and inSession and entropyPct > 68.0 and anomalyRank < 45.0 and math.abs(phasePressure) < 22.0

color phaseColor = phasePressure >= 0.0 ? color.from_gradient(latticeScore, 0.0, 100.0, C_TEAL, C_CYAN) : color.from_gradient(latticeScore, 0.0, 100.0, C_CORAL, C_MAGENTA)
color quietColor = color.from_gradient(entropyPct, 0.0, 100.0, C_CYAN, C_GOLD)

pMean = plot(showOrbitBands and inSession ? orbitMean : na, "SIL orbit mean", color=color.new(phaseColor, 0), linewidth=2)
pUpper = plot(showOrbitBands and inSession ? upperOrbit : na, "SIL upper orbit", color=color.new(phaseColor, 28), linewidth=1)
pLower = plot(showOrbitBands and inSession ? lowerOrbit : na, "SIL lower orbit", color=color.new(phaseColor, 28), linewidth=1)
pOuterUp = plot(showOrbitBands and inSession ? upperOuter : na, "SIL upper anomaly", color=color.new(C_GOLD, 58), linewidth=1)
pOuterDn = plot(showOrbitBands and inSession ? lowerOuter : na, "SIL lower anomaly", color=color.new(C_GOLD, 58), linewidth=1)
fill(pUpper, pLower, color=color.new(phaseColor, 91), title="SIL orbit field")
fill(pOuterUp, pUpper, color=color.new(C_MAGENTA, 95), title="SIL upper anomaly field")
fill(pLower, pOuterDn, color=color.new(C_CYAN, 95), title="SIL lower anomaly field")
plot(inSession ? sessionVwap : na, "SIL session VWAP", color=color.new(C_GOLD, 8), linewidth=2)
barcolor(paintCandles and inSession ? color.new(balanceCompression ? quietColor : phaseColor, latticeScore > phaseGate ? 4 : 34) : na)
bgcolor(balanceCompression ? color.new(C_GOLD, 94) : na, title="SIL balance compression")

var box[] phaseBoxes = array.new_box()
var label[] phaseLabels = array.new_label()

f_prune() =>
    while array.size(phaseBoxes) > maxCells
        box.delete(array.shift(phaseBoxes))
    while array.size(phaseLabels) > maxCells
        label.delete(array.shift(phaseLabels))

f_phaseCell(bool upperSide, string msg) =>
    color base = upperSide ? C_MAGENTA : C_CYAN
    float top = upperSide ? high + atr * 0.20 : low + atr * 0.45
    float bot = upperSide ? high - atr * 0.45 : low - atr * 0.20
    int x2 = bar_index + cellLife
    array.push(phaseBoxes, box.new(bar_index, top, x2, bot, xloc=xloc.bar_index, bgcolor=color.new(base, 87), border_color=color.new(base, 20), text=msg, text_color=C_TEXT, text_size=size.tiny))
    array.push(phaseLabels, label.new(x2, (top + bot) * 0.5, msg, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(base, 12), textcolor=upperSide ? C_TEXT : color.rgb(5, 10, 14), size=size.tiny))
    f_prune()

if showPhaseCells and upperPhaseEvent
    f_phaseCell(true, "SIL UPPER ORBIT\n" + f_phaseName(phase) + "\nScore " + str.tostring(latticeScore, "#"))
if showPhaseCells and lowerPhaseEvent
    f_phaseCell(false, "SIL LOWER ORBIT\n" + f_phaseName(phase) + "\nScore " + str.tostring(latticeScore, "#"))
if showPhaseCells and balanceCompression
    f_phaseCell(phasePressure >= 0.0, "SIL BALANCE\nEntropy " + str.tostring(entropyPct, "#"))

var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(C_PANEL, 4), border_color=color.new(C_VIOLET, 45), border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Sidereal Lattice", text_color=C_TEXT, bgcolor=color.new(phaseColor, 65), text_size=size.small)
    table.cell(dash, 1, 0, inSession ? f_phaseName(phase) : "CLOSED", text_color=phaseColor, bgcolor=color.new(phaseColor, 65), text_size=size.small)
    table.cell(dash, 0, 1, "Phase", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(phase * 100.0, "#.0") + "%", text_color=phaseColor, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 2, "Lattice", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(latticeScore, "#.0"), text_color=color.from_gradient(latticeScore, 0.0, 100.0, C_CORAL, C_CYAN), bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 3, "Drift ATR", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(driftAtr, "#.00"), text_color=driftAtr >= 0 ? C_CYAN : C_MAGENTA, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 4, "Entropy", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(entropyPct, "#.0") + "%", text_color=quietColor, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 5, "Anomaly", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(anomalyRank, "#.0") + "%", text_color=color.from_gradient(anomalyRank, 0.0, 100.0, C_TEAL, C_MAGENTA), bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 6, "Pressure", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(phasePressure, "#.0"), text_color=phasePressure >= 0.0 ? C_CYAN : C_MAGENTA, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 7, "VWAP", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 7, str.tostring(sessionVwap, format.mintick), text_color=C_GOLD, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 8, "State", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 8, upperPhaseEvent ? "UPPER EVENT" : lowerPhaseEvent ? "LOWER EVENT" : balanceCompression ? "BALANCE" : "TRACKING", text_color=upperPhaseEvent ? C_MAGENTA : lowerPhaseEvent ? C_CYAN : balanceCompression ? C_GOLD : C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)

alertcondition(upperPhaseEvent, "SIL Upper Orbit Event [JOAT]", "Sidereal Session Lattice [JOAT]: upper session orbit anomaly confirmed.")
alertcondition(lowerPhaseEvent, "SIL Lower Orbit Event [JOAT]", "Sidereal Session Lattice [JOAT]: lower session orbit anomaly confirmed.")
alertcondition(balanceCompression, "SIL Balance Compression [JOAT]", "Sidereal Session Lattice [JOAT]: entropy balance compression confirmed.")
````

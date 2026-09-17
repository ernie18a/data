<!-- tradingview-pine-id: PUB;1bf9159710cc43358241f53552095764 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Phase Space Quadrant Dashboard [FibonacciFlux]

Source: https://www.tradingview.com/script/1DmFbXWk-Phase-Space-Quadrant-Dashboard-FibonacciFlux/

## Description

Four timeframes plotted as four points on one oscillator plane, published with the measurement that says the states it draws do not forecast anything.

WHAT IT DRAWS

Each of four timeframes (15m, 1H, 4H, 1D by default) becomes a point on a plane: x is RSI minus 50 over 50, y is Stochastic %K minus 50 over 50. Four points, one plane, all bounded to the same square.

From those points it computes a weighted centroid, the weighted dispersion around it, and three terms that are fused as a geometric mean: Tight (how small the dispersion is against a reference), Dir (how much the four timeframes agree on rotation direction, clockwise counting as bull) and Mag (how far the centroid sits from the origin). The fusion is evaluated as a bull and a bear score, because a geometric mean of a signed quantity is undefined. A 3x3 map shows which cell the centroid occupies, with a gauge for dispersion against the reference, and a diamond marks a bar where a timeframe crossed a quadrant boundary while the cluster was tight.

WHAT THE MEASUREMENT FOUND

None of the states separate from chance.

Testing all seventeen states this dashboard advertises at once - counted as episodes rather than as overlapping bars, against 500 circular shifts of the forward-return series - the largest standardised effect anywhere in the family is 1.76, 1.37 and 1.54 at horizons of 4, 16 and 96 bars, against a null that averages 2.11, 2.07 and 1.95. The family-wise p-values are 0.689, 0.936 and 0.838. The dashboard is less extreme than a randomly misaligned copy of itself, and the same test fails in all twelve instrument-by-timeframe-by-horizon cells.

One result did not die, and it is worth stating precisely because the tempting version of it is wrong. Bars where Tight is at or above 0.50 are followed by larger absolute moves on BINANCE:BTCUSDT 15m: measured at episode level, the four-bar-forward absolute return is 1.227 times the baseline, z = 1.91, p = 0.040, over 134 episodes. Counted per bar it looks stronger - 1.269 times, p = 0.004 - but that number counts 951 overlapping bars belonging to those same 134 episodes, so it is the weaker statistic that is honest. It is a statement about the size of moves, not their direction, on one instrument, at p just under 0.05.

There is a third thing that looks like a finding and is not. The four timeframes' points do cluster far more tightly than a null that rotates each timeframe to an unrelated point in time - z of 3.8 to 6.1 across four instrument-and-timeframe cells. That null is not one anybody should believe: the four legs are nested views of the same price series, so they agree by construction, and a random walk passes the same test. It is arithmetic about multi-timeframe indicators in general, not evidence about this one.

No edge is claimed. There is no forward-return figure here presented as a signal, and the alerts say in their own text that they describe geometry rather than predict anything.

THE SETTING THAT GOVERNS EVERYTHING

Sigma reference for Tight, default 0.50, is the master gain, and the default sits on the edge of the data. Tight is one minus dispersion over that reference, clipped at zero, so the reference decides how often the whole fusion score exists at all. Measured over 5,984 scored bars of BTCUSDT 15m the median dispersion is 0.414 - 83% of the reference - which puts median Tight at 0.180 and pins Tight, and therefore both scores, at exactly zero on 27.3% of bars. On ETHUSDT it is 21.6%. Drop the reference to 0.40 and the median score is zero; raise it to 2.0 and the median more than doubles. Anyone changing that one number is changing what every other number here means.

The score threshold at 0.55 is selective but reachable: the higher of the two scores clears it on 377 bars of the 5,984, producing 31 bull and 65 bear crossings on BTCUSDT, and 370 bars with 41 and 58 crossings on ETHUSDT. Quadrant-shift diamonds appear 163 times.

WHAT THE MEASUREMENTS COVER

The 15m results run from 2026-06-21 to 2026-08-23, 62 days, in a market that rose about 18% over the window. The 1H results reach back to 2026-04-20, about 125 days. Nothing here was tested outside that window, in a falling market, or on a non-crypto instrument.

HOW THE NUMBERS WERE CHECKED

The whole computation - the two oscillators per timeframe, the higher-timeframe mapping, the centroid and dispersion, the hysteresis on the quadrant bands, the rotation test and the fused scores - was reimplemented outside Pine and cross-checked against this chart's Data Window on ten bars, including one carrying a quadrant-shift marker so the event path was exercised rather than assumed. All fifty values round to the exact three decimals TradingView prints. The bull and bear scores were also confirmed to be mutually exclusive on all 6,000 bars, which is structural rather than coincidental.

WHAT CHANGED IN THIS VERSION

A phase audit table promised by the settings and by five helper functions did not exist anywhere in the file; the promise was deleted rather than the table built. The 3x3 quadrant map, which is real, stays. The header carried two lineage claims - an inherited "DNA" from another indicator and a reference to a private specification - that told a reader nothing, and they are gone. An MPL header was added and a leftover compile-sentinel plot removed. The two threshold inputs now carry the measurements above in their tooltips, and the alert messages say plainly that they describe geometry. No computation changed.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("Phase Space Quadrant Dashboard [FibonacciFlux]", "Phase Quad", overlay = false, precision = 3)
// MTF phase-space dashboard. Each timeframe is a point P = (x, y) on the
// oscillator plane, x = (RSI - 50) / 50 and y = (Stoch K - 50) / 50.
// The weighted centroid and the circle around it summarise where the four
// timeframes sit on that plane and how far apart they are.
// Fusion score: G = (Tight * Dir * Mag)^(1/3), evaluated as a bull/bear pair
// because a geometric mean of a signed Dir is undefined.
// Bull rotation = clockwise travel in this plane (Stoch leads RSI).
// Pine v6 has no math.atan2, so a quadrant-aware f_atan2() is built here from
// single-argument math.atan().

// -----------------------------------------------------------------------------
// 01. Oscillator sensors
// -----------------------------------------------------------------------------
string G_OSC = "01. Oscillator sensors"
sourceInput = input.source(close, "Source", group = G_OSC)
int rsiLength = input.int(14, "RSI length", minval = 2, group = G_OSC)
int stochLength = input.int(14, "Stochastic length", minval = 2, group = G_OSC)
int kSmooth = input.int(3, "Stochastic %K smoothing", minval = 1, group = G_OSC)
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_OSC,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe. Developing HTF reacts earlier but changes until the open higher-timeframe bar closes.")

// -----------------------------------------------------------------------------
// 02. Timeframes and weights
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes and weights"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF)
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Phase geometry
// -----------------------------------------------------------------------------
string G_GEO = "03. Phase geometry"
float sigmaRef = input.float(0.50, "Sigma reference for Tight", minval = 0.05, maxval = 2.0, step = 0.05, group = G_GEO,
     tooltip = "The master gain of this indicator, and the default sits on the edge of the data. Tight = 1 - dispersion/sigmaRef clipped to [0,1], and measured over 5984 scored bars of BINANCE:BTCUSDT 15m the median dispersion is 0.414 - 83% of the reference - so median Tight is 0.180 and Tight, and therefore the whole fusion score, is pinned at exactly 0 on 27.3% of bars (21.6% on ETHUSDT). Lower this and the score dies entirely; at 0.40 and below its median is 0. Raise it and everything lifts: the median score runs 0.194 at the default against 0.423 at 2.0.")
float hystBand = input.float(0.05, "Quadrant hysteresis band", minval = 0.0, maxval = 0.25, step = 0.01, group = G_GEO)
float tightThreshold = input.float(0.50, "Tight threshold for shift alerts", minval = 0.0, maxval = 1.0, step = 0.05, group = G_GEO)
float gThreshold = input.float(0.55, "Phase-lock score threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = G_GEO,
     tooltip = "Reachable but selective: on BINANCE:BTCUSDT 15m over 5984 scored bars the higher of the two scores clears 0.55 on 377 bars, producing 31 bull and 65 bear crossings; ETHUSDT gives 370 bars, 41 and 58. Score median 0.200, 95th percentile 0.575, maximum 0.864.")
bool signalOnClose = input.bool(true, "Alerts only on confirmed chart bars", group = G_GEO)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool showMap = input.bool(true, "Show 3x3 quadrant map", group = G_VIS)

// -----------------------------------------------------------------------------
// Numeric helpers
// -----------------------------------------------------------------------------
float EPS = 1e-10

f_clip(float value, float lower, float upper) => math.max(lower, math.min(upper, value))

// Quadrant-aware arctangent in (-pi, pi]; na at the origin and on na input.
f_atan2(float y, float x) =>
    float angle = na
    if x > 0.0
        angle := math.atan(y / x)
    else if x < 0.0
        angle := y >= 0.0 ? math.atan(y / x) + math.pi : math.atan(y / x) - math.pi
    else if y > 0.0
        angle := math.pi / 2.0
    else if y < 0.0
        angle := -math.pi / 2.0
    angle

// Wrap an angle difference into (-pi, pi] so crossings near +-pi do not spike.
f_wrapAngle(float a) =>
    float wrapped = a
    if wrapped > math.pi
        wrapped -= 2.0 * math.pi
    if wrapped <= -math.pi
        wrapped += 2.0 * math.pi
    wrapped

f_num(float value, string fmt) => na(value) ? "-" : str.tostring(value, fmt)

f_pct(float value) => na(value) ? "-" : str.tostring(100.0 * value, "#.0")

// Raw band classifier for the 3x3 map: -1 / 0 / +1 (0 also covers na).
f_band(float v, float band) =>
    na(v) ? 0 : v > band ? 1 : v < -band ? -1 : 0

// The complete phase point is evaluated inside each requested timeframe.
// dTheta is the wrapped per-HTF-bar angle change of the point itself, so it
// stays meaningful (non-sparse) even when many chart bars share one HTF bar.
f_phase() =>
    float rsiValue = ta.rsi(sourceInput, rsiLength)
    float kValue = ta.sma(ta.stoch(close, high, low, stochLength), kSmooth)
    float x = (rsiValue - 50.0) / 50.0
    float y = (kValue - 50.0) / 50.0
    float theta = f_atan2(y, x)
    float dTheta = f_wrapAngle(theta - nz(theta[1], theta))
    [x, y, rsiValue, kValue, dTheta]

f_phaseConfirmed() =>
    [x, y, rsiValue, kValue, dTheta] = f_phase()
    [x[1], y[1], rsiValue[1], kValue[1], dTheta[1]]

[x15Dev, y15Dev, rsi15Dev, k15Dev, dTh15Dev] = request.security(syminfo.tickerid, tf15, f_phase(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[x1hDev, y1hDev, rsi1hDev, k1hDev, dTh1hDev] = request.security(syminfo.tickerid, tf1h, f_phase(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[x4hDev, y4hDev, rsi4hDev, k4hDev, dTh4hDev] = request.security(syminfo.tickerid, tf4h, f_phase(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[x1dDev, y1dDev, rsi1dDev, k1dDev, dTh1dDev] = request.security(syminfo.tickerid, tf1d, f_phase(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[x15Con, y15Con, rsi15Con, k15Con, dTh15Con] = request.security(syminfo.tickerid, tf15, f_phaseConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[x1hCon, y1hCon, rsi1hCon, k1hCon, dTh1hCon] = request.security(syminfo.tickerid, tf1h, f_phaseConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[x4hCon, y4hCon, rsi4hCon, k4hCon, dTh4hCon] = request.security(syminfo.tickerid, tf4h, f_phaseConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[x1dCon, y1dCon, rsi1dCon, k1dCon, dTh1dCon] = request.security(syminfo.tickerid, tf1d, f_phaseConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

confirmedMode = dataMode == "Confirmed only"
float x15 = confirmedMode ? x15Con : x15Dev
float x1h = confirmedMode ? x1hCon : x1hDev
float x4h = confirmedMode ? x4hCon : x4hDev
float x1d = confirmedMode ? x1dCon : x1dDev
float y15 = confirmedMode ? y15Con : y15Dev
float y1h = confirmedMode ? y1hCon : y1hDev
float y4h = confirmedMode ? y4hCon : y4hDev
float y1d = confirmedMode ? y1dCon : y1dDev
float rsi15 = confirmedMode ? rsi15Con : rsi15Dev
float rsi1h = confirmedMode ? rsi1hCon : rsi1hDev
float rsi4h = confirmedMode ? rsi4hCon : rsi4hDev
float rsi1d = confirmedMode ? rsi1dCon : rsi1dDev
float k15 = confirmedMode ? k15Con : k15Dev
float k1h = confirmedMode ? k1hCon : k1hDev
float k4h = confirmedMode ? k4hCon : k4hDev
float k1d = confirmedMode ? k1dCon : k1dDev
float dTh15 = confirmedMode ? dTh15Con : dTh15Dev
float dTh1h = confirmedMode ? dTh1hCon : dTh1hDev
float dTh4h = confirmedMode ? dTh4hCon : dTh4hDev
float dTh1d = confirmedMode ? dTh1dCon : dTh1dDev

// Normalize weights onto a simplex; all-zero input falls back to defaults.
float rawWeightSum = w15Input + w1hInput + w4hInput + w1dInput
bool fallbackWeights = rawWeightSum <= 0.0
float weightSum = fallbackWeights ? 1.0 : rawWeightSum
float w15 = (fallbackWeights ? 0.10 : w15Input) / weightSum
float w1h = (fallbackWeights ? 0.20 : w1hInput) / weightSum
float w4h = (fallbackWeights ? 0.40 : w4hInput) / weightSum
float w1d = (fallbackWeights ? 0.30 : w1dInput) / weightSum

// -----------------------------------------------------------------------------
// Centroid, dispersion circle, and fusion components
// -----------------------------------------------------------------------------
float cx = w15 * x15 + w1h * x1h + w4h * x4h + w1d * x1d
float cy = w15 * y15 + w1h * y1h + w4h * y4h + w1d * y1d
bool warm = not na(cx) and not na(cy) and not na(dTh15) and not na(dTh1h) and not na(dTh4h) and not na(dTh1d)
float dispersionVar = w15 * (math.pow(x15 - cx, 2.0) + math.pow(y15 - cy, 2.0)) + w1h * (math.pow(x1h - cx, 2.0) + math.pow(y1h - cy, 2.0)) + w4h * (math.pow(x4h - cx, 2.0) + math.pow(y4h - cy, 2.0)) + w1d * (math.pow(x1d - cx, 2.0) + math.pow(y1d - cy, 2.0))
float dispersion = math.sqrt(math.max(dispersionVar, 0.0))
float tight = warm ? f_clip(1.0 - dispersion / sigmaRef, 0.0, 1.0) : na
float mag = math.sqrt(cx * cx + cy * cy)
// |P*| can reach sqrt(2) at a corner; it is capped at 1 for the 0-1 G scale.
float magC = f_clip(mag, 0.0, 1.0)

// Rotation agreement. Bull rotation is defined as CLOCKWISE travel in the
// (RSI, Stoch) plane, i.e. dTheta < 0: Stoch (y) leads RSI (x), tracing
// Q3 > Q2 > Q1 on the way up and Q1 > Q4 > Q3 on the way down. Counter-
// clockwise travel (dTheta > 0, RSI leads Stoch) feeds the bear side.
// This sign convention is a working hypothesis from the design spec.
float rot15 = na(dTh15) ? 0.0 : -math.sign(dTh15)
float rot1h = na(dTh1h) ? 0.0 : -math.sign(dTh1h)
float rot4h = na(dTh4h) ? 0.0 : -math.sign(dTh4h)
float rot1d = na(dTh1d) ? 0.0 : -math.sign(dTh1d)
float dir = w15 * rot15 + w1h * rot1h + w4h * rot4h + w1d * rot1d
float bullDir = math.max(dir, 0.0)
float bearDir = math.max(-dir, 0.0)
float gBull = warm ? math.pow(tight * bullDir * magC, 1.0 / 3.0) : na
float gBear = warm ? math.pow(tight * bearDir * magC, 1.0 / 3.0) : na
float stateStrength = warm ? 100.0 * math.max(gBull, gBear) : na

// -----------------------------------------------------------------------------
// Quadrant state machine with per-axis hysteresis
// -----------------------------------------------------------------------------
// An axis flips its side only beyond +-hystBand; inside the band the previous
// side sticks, which suppresses quadrant flicker near the 50 lines.
float xSide15 = na
xSide15 := na(x15) ? nz(xSide15[1], 0.0) : x15 > hystBand ? 1.0 : x15 < -hystBand ? -1.0 : nz(xSide15[1], 0.0)
float xSide1h = na
xSide1h := na(x1h) ? nz(xSide1h[1], 0.0) : x1h > hystBand ? 1.0 : x1h < -hystBand ? -1.0 : nz(xSide1h[1], 0.0)
float xSide4h = na
xSide4h := na(x4h) ? nz(xSide4h[1], 0.0) : x4h > hystBand ? 1.0 : x4h < -hystBand ? -1.0 : nz(xSide4h[1], 0.0)
float xSide1d = na
xSide1d := na(x1d) ? nz(xSide1d[1], 0.0) : x1d > hystBand ? 1.0 : x1d < -hystBand ? -1.0 : nz(xSide1d[1], 0.0)
float ySide15 = na
ySide15 := na(y15) ? nz(ySide15[1], 0.0) : y15 > hystBand ? 1.0 : y15 < -hystBand ? -1.0 : nz(ySide15[1], 0.0)
float ySide1h = na
ySide1h := na(y1h) ? nz(ySide1h[1], 0.0) : y1h > hystBand ? 1.0 : y1h < -hystBand ? -1.0 : nz(ySide1h[1], 0.0)
float ySide4h = na
ySide4h := na(y4h) ? nz(ySide4h[1], 0.0) : y4h > hystBand ? 1.0 : y4h < -hystBand ? -1.0 : nz(ySide4h[1], 0.0)
float ySide1d = na
ySide1d := na(y1d) ? nz(ySide1d[1], 0.0) : y1d > hystBand ? 1.0 : y1d < -hystBand ? -1.0 : nz(ySide1d[1], 0.0)

// Quadrant codes: Q1 (x+, y+) bull run, Q2 (x-, y+) early recovery,
// Q3 (x-, y-) bear run, Q4 (x+, y-) early rollover, 0 = unresolved.
f_quad(float xs, float ys) =>
    xs > 0.0 ? (ys > 0.0 ? 1 : ys < 0.0 ? 4 : 0) : xs < 0.0 ? (ys > 0.0 ? 2 : ys < 0.0 ? 3 : 0) : 0

int q15 = f_quad(xSide15, ySide15)
int q1h = f_quad(xSide1h, ySide1h)
int q4h = f_quad(xSide4h, ySide4h)
int q1d = f_quad(xSide1d, ySide1d)

bool shift15 = q15 != 0 and q15[1] != 0 and q15 != q15[1]
bool shift1h = q1h != 0 and q1h[1] != 0 and q1h != q1h[1]
bool shift4h = q4h != 0 and q4h[1] != 0 and q4h != q4h[1]
bool shift1d = q1d != 0 and q1d[1] != 0 and q1d != q1d[1]
bool anyShift = shift15 or shift1h or shift4h or shift1d

var string lastShift15 = "-"
var string lastShift1h = "-"
var string lastShift4h = "-"
var string lastShift1d = "-"
if shift15
    lastShift15 := "Q" + str.tostring(q15[1]) + ">Q" + str.tostring(q15)
if shift1h
    lastShift1h := "Q" + str.tostring(q1h[1]) + ">Q" + str.tostring(q1h)
if shift4h
    lastShift4h := "Q" + str.tostring(q4h[1]) + ">Q" + str.tostring(q4h)
if shift1d
    lastShift1d := "Q" + str.tostring(q1d[1]) + ">Q" + str.tostring(q1d)

// -----------------------------------------------------------------------------
// Alerts and pane visuals
// -----------------------------------------------------------------------------
chartBarGate = not signalOnClose or barstate.isconfirmed
bool tightOK = not na(tight) and tight >= tightThreshold
bool shiftEvent = chartBarGate and anyShift and tightOK
bool bullEvent = chartBarGate and not na(gBull) and gBull >= gThreshold and (na(gBull[1]) or gBull[1] < gThreshold)
bool bearEvent = chartBarGate and not na(gBear) and gBear >= gThreshold and (na(gBear[1]) or gBear[1] < gThreshold)
alertcondition(shiftEvent, "Phase quadrant shift with tight cluster", "A timeframe crossed a phase-space quadrant boundary while the cluster was tight.")
alertcondition(bullEvent, "Bull phase-lock", "Tight cluster, bull rotation agreement and centroid magnitude fused above threshold. This is a description of the current geometry, not a forecast: tested against a null that circularly shifts the forward returns, none of the states this dashboard draws separated from chance.")
alertcondition(bearEvent, "Bear phase-lock", "Tight cluster, bear rotation agreement and centroid magnitude fused above threshold. This is a description of the current geometry, not a forecast: tested against a null that circularly shifts the forward returns, none of the states this dashboard draws separated from chance.")

plot(gBull, "Bull phase-lock score", color = color.new(color.lime, 0), linewidth = 2)
plot(gBear, "Bear phase-lock score", color = color.new(color.red, 0), linewidth = 2)
plot(tight, "Cluster tightness", color = color.new(color.aqua, 25), linewidth = 1)
plot(gThreshold, "Phase-lock threshold", color = color.new(color.gray, 45), linewidth = 1)
plotshape(shiftEvent, "Quadrant shift marker", style = shape.diamond, location = location.bottom, color = color.new(color.yellow, 15), size = size.tiny)

// -----------------------------------------------------------------------------
// 3x3 quadrant map (raw band positions; hysteresis states live in the audit)
// -----------------------------------------------------------------------------
int bx15 = (na(x15) or na(y15)) ? 99 : f_band(x15, hystBand)
int by15 = (na(x15) or na(y15)) ? 99 : f_band(y15, hystBand)
int bx1h = (na(x1h) or na(y1h)) ? 99 : f_band(x1h, hystBand)
int by1h = (na(x1h) or na(y1h)) ? 99 : f_band(y1h, hystBand)
int bx4h = (na(x4h) or na(y4h)) ? 99 : f_band(x4h, hystBand)
int by4h = (na(x4h) or na(y4h)) ? 99 : f_band(y4h, hystBand)
int bx1d = (na(x1d) or na(y1d)) ? 99 : f_band(x1d, hystBand)
int by1d = (na(x1d) or na(y1d)) ? 99 : f_band(y1d, hystBand)
int bcx = (na(cx) or na(cy)) ? 99 : f_band(cx, hystBand)
int bcy = (na(cx) or na(cy)) ? 99 : f_band(cy, hystBand)

f_cellText(int bandX, int bandY) =>
    string t = ""
    if bx15 == bandX and by15 == bandY
        t := t + "15m "
    if bx1h == bandX and by1h == bandY
        t := t + "1H "
    if bx4h == bandX and by4h == bandY
        t := t + "4H "
    if bx1d == bandX and by1d == bandY
        t := t + "1D "
    if bcx == bandX and bcy == bandY
        t := t + "*"
    t

f_cellBg(int bandX, int bandY, bool hot) =>
    color base = bandY == 1 and bandX == 1 ? color.lime : bandY == 1 and bandX == -1 ? color.aqua : bandY == -1 and bandX == -1 ? color.red : bandY == -1 and bandX == 1 ? color.orange : color.gray
    color.new(base, hot ? 30 : 80)

f_gauge(float fraction) =>
    int filled = int(math.round(f_clip(fraction, 0.0, 1.0) * 10.0))
    string gauge = ""
    for i = 1 to 10
        gauge := gauge + (i <= filled ? "#" : "-")
    gauge

var table mapTable = table.new(position.middle_right, 4, 5, border_width = 1)
if barstate.islast and showMap
    color mHeader = color.rgb(32, 38, 48)
    color mBody = color.new(color.black, 20)
    table.cell(mapTable, 0, 0, "y/x", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 1, 0, "x-", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 2, 0, "x0", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 3, 0, "x+", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 0, 1, "y+", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 0, 2, "y0", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 0, 3, "y-", bgcolor = mHeader, text_color = color.white, text_size = size.small)
    // Grid: column = bandX + 2, row = 2 - bandY. Centroid cell is highlighted.
    for bandX = -1 to 1
        for bandY = -1 to 1
            bool hot = bcx == bandX and bcy == bandY
            table.cell(mapTable, bandX + 2, 2 - bandY, f_cellText(bandX, bandY), bgcolor = f_cellBg(bandX, bandY, hot), text_color = color.white, text_size = size.small)
    float gaugeFrac = f_clip(dispersion / sigmaRef, 0.0, 1.0)
    table.cell(mapTable, 0, 4, "Sigma/ref", bgcolor = mBody, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 1, 4, na(gaugeFrac) ? "----------" : f_gauge(gaugeFrac), bgcolor = mBody, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 2, 4, na(gaugeFrac) ? "-" : f_pct(gaugeFrac) + " %", bgcolor = mBody, text_color = color.white, text_size = size.small)
    table.cell(mapTable, 3, 4, "Tight " + (na(tight) ? "-" : f_pct(tight) + " %"), bgcolor = mBody, text_color = color.white, text_size = size.small)
````
